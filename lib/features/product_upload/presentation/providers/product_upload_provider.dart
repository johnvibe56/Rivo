import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:rivo/core/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final productUploadProvider = StateNotifierProvider<ProductUploadNotifier, ProductUploadState>(
  (ref) => ProductUploadNotifier(),
);

class ProductUploadState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ProductUploadState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ProductUploadState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return ProductUploadState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProductUploadNotifier extends StateNotifier<ProductUploadState> {
  final SupabaseClient _supabase;
  final StorageService _storageService;

  ProductUploadNotifier() : 
    _supabase = Supabase.instance.client,
    _storageService = StorageService(Supabase.instance.client),
    super(ProductUploadState());

  Future<bool> uploadProduct(Map<String, dynamic> productData) async {
    // Reset state and set loading to true
    state = state.copyWith(
      isLoading: true, 
      error: null,
      isSuccess: false,
    );

    // Get current user ID
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'User not authenticated',
      );
      return false;
    }

      debugPrint('Starting image upload...');
      
      // 1. Upload the image to Supabase Storage
      File? imageFile;
      try {
        imageFile = productData['image_file'] as File?;
        if (imageFile == null || !await imageFile.exists()) {
          throw Exception('Image file is invalid or does not exist');
        }
        
        debugPrint('Image file exists, size: ${await imageFile.length()} bytes');
        
        final imageUrl = await _storageService.uploadFile(
          file: imageFile,
          userId: userId,
        );

        debugPrint('Image uploaded successfully: $imageUrl');

        if (imageUrl.isEmpty) {
          throw Exception('Failed to get image URL after upload');
        }

        debugPrint('Creating product record...');
        
        // 2. Create product record in the database
        await _createProductRecord(
          title: productData['title'] as String,
          description: productData['description'] as String,
          price: productData['price'] as double,
          imageUrl: imageUrl,
        );

        debugPrint('Product created successfully');
        
        // Update state to indicate success
        state = state.copyWith(
          isLoading: false, 
          isSuccess: true,
          error: null,
        );
        
        return true;
      } catch (e, stackTrace) {
        debugPrint('Error in uploadProduct:');
        debugPrint(e.toString());
        debugPrint('Stack trace:');
        debugPrint(stackTrace.toString());
        
        // If we have an image file, try to clean it up
        if (imageFile != null) {
          debugPrint('Attempting to clean up failed upload...');
          try {
            // Extract the file path from the URL if possible
            final fileName = imageFile.path.split('/').last;
            final filePath = 'user_$userId/${DateTime.now().millisecondsSinceEpoch}${path.extension(fileName).toLowerCase()}';
            await _supabase.storage
                .from('product-images')
                .remove([filePath]);
            debugPrint('Cleaned up failed upload');
          } catch (cleanupError) {
            debugPrint('Error during cleanup: $cleanupError');
          }
        }
        
        // Update state with error
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
          isSuccess: false,
        );
        return false;
      }
  }

  // Removed _uploadImage as we're now using StorageService

  Future<void> _createProductRecord({
    required String title,
    required String description,
    required double price,
    required String imageUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('products').insert({
        'title': title,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'owner_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  void reset() {
    state = ProductUploadState();
  }
}

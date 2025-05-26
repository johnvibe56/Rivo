import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('You must be logged in to upload a product');
      }
      
      final userId = user.id;
      debugPrint('Starting product upload for user: $userId');
      debugPrint('Product data: ${{
        'title': productData['title'],
        'price': productData['price'],
        'has_image': productData['image_file'] != null,
      }}');
      
      // 1. Upload the image to Supabase Storage
      File? imageFile = productData['image_file'] as File?;
      if (imageFile == null || !await imageFile.exists()) {
        throw Exception('Please select a valid image for the product');
      }
      
      debugPrint('Image file exists, size: ${await imageFile.length()} bytes');
      
      // Upload the image first
      debugPrint('Uploading image to storage...');
      final imageUrl = await _storageService.uploadFile(
        file: imageFile,
        userId: userId,
      );

      if (imageUrl.isEmpty) {
        throw Exception('Failed to upload image. Please try again.');
      }
      debugPrint('Image uploaded successfully: $imageUrl');

      // 2. Create product record in the database
      debugPrint('Creating product record...');
      await _createProductRecord(
        title: productData['title'] as String,
        description: productData['description'] as String? ?? '',
        price: (productData['price'] as num).toDouble(),
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
      
      // Clean up any uploaded files if there was an error
      try {
        if (e is! Exception || !e.toString().contains('select a valid image')) {
          // Only attempt cleanup if we actually uploaded a file
          final imageFile = productData['image_file'] as File?;
          if (imageFile != null && await imageFile.exists()) {
            debugPrint('Attempting to clean up failed upload...');
            final fileName = imageFile.path.split('/').last;
            final filePath = 'user_${_supabase.auth.currentUser?.id ?? 'unknown'}/$fileName';
            await _supabase.storage
                .from('product-images')
                .remove([filePath]);
            debugPrint('Cleaned up failed upload');
          }
        }
      } catch (cleanupError) {
        debugPrint('Error during cleanup: $cleanupError');
      }
      
      // Update state with error
      String errorMessage = 'An error occurred while uploading the product';
      if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
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
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please log in to upload products.');
      }
      
      final ownerId = user.id;
      debugPrint('Creating product record for owner: $ownerId');
      
      // Prepare product data with owner_id and properly typed UUID arrays
      final productData = {
        'title': title,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'owner_id': ownerId,
        'created_at': DateTime.now().toIso8601String(),
        // Use raw SQL array syntax for UUID arrays
        'liked_by': '{}',  // Empty SQL UUID array
        'saved_by': '{}',  // Empty SQL UUID array
      };
      
      debugPrint('Inserting product with data: $productData');
      
      // Insert the product
      final response = await _supabase
          .from('products')
          .insert(productData)
          .select()
          .single();
          
      debugPrint('Product created successfully with ID: ${response['id']}');
    } on PostgrestException catch (e) {
      debugPrint('Database error: ${e.message}');
      debugPrint('Details: ${e.details}');
      debugPrint('Hint: ${e.hint}');
      throw Exception('Failed to save product to database: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error in _createProductRecord: $e');
      rethrow;
    }
  }

  void reset() {
    state = ProductUploadState();
  }
}

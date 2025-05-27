import 'dart:io';
import 'dart:math' show pow, log;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class StorageException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  StorageException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() => 'StorageException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${error != null ? '\n$error' : ''}';
}

class StorageService {
  final SupabaseClient _supabase;
  static const String _bucketName = 'product-images';

  StorageService(this._supabase);

  /// Helper to get MIME type from file extension
  String? _getMimeType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.svg':
        return 'image/svg+xml';
      default:
        return null;
    }
  }

  /// Validates the file before upload
  Future<void> _validateFile(File file) async {
    if (!await file.exists()) {
      throw StorageException(message: 'File does not exist');
    }

    final fileSize = await file.length();
    if (fileSize == 0) {
      throw StorageException(message: 'File is empty');
    }

    // 10MB limit
    const maxSize = 10 * 1024 * 1024;
    if (fileSize > maxSize) {
      throw StorageException(
        message: 'File size exceeds maximum allowed size of 10MB',
      );
    }
  }

  /// Validates the file path
  String _validateAndCreatePath(String userId, String filePath) {
    if (userId.isEmpty) {
      throw StorageException(message: 'User ID cannot be empty');
    }

    final fileExt = path.extension(filePath).toLowerCase();
    if (fileExt.isEmpty) {
      throw StorageException(message: 'File must have an extension');
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
    return 'user_$userId/$fileName';
  }

  /// Uploads a file to Supabase Storage and returns the public URL
  /// 
  /// Throws [StorageException] if the upload fails
  Future<String> uploadFile({
    required File file,
    required String userId,
    String? customPath,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Validate inputs
      if (userId.trim().isEmpty) {
        throw StorageException(message: 'User ID cannot be empty');
      }

      debugPrint('🚀 Starting file upload for user: $userId');
      debugPrint('📂 File path: ${file.path}');
      
      // Validate file
      await _validateFile(file);
      final fileSize = await file.length();
      debugPrint('📊 File size: ${_formatBytes(fileSize)}');

      // Generate file path
      final filePath = _validateAndCreatePath(userId, file.path);
      debugPrint('📍 Generated file path: $filePath');

      // Read file as bytes
      final fileBytes = await _readFileInChunks(file);
      debugPrint('📥 Read ${_formatBytes(fileBytes.length)} from file');

      // Get MIME type
      final contentType = _getMimeType(file.path) ?? 'application/octet-stream';
      debugPrint('🔍 Detected content type: $contentType');

      // Upload the file
      debugPrint('⬆️  Starting upload to Supabase...');
      final uploadTime = await _uploadWithRetry(
        filePath: filePath,
        fileBytes: fileBytes,
        contentType: contentType,
      );
      
      debugPrint('✅ File uploaded successfully in ${uploadTime.inMilliseconds}ms');

      // Get public URL
      debugPrint('🔗 Getting public URL...');
      final publicUrl = _getPublicUrl(filePath);
      debugPrint('🌐 Public URL: $publicUrl');
      
      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in uploadFile:');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      
      if (e is! StorageException) {
        throw StorageException(
          message: 'Failed to upload file',
          error: e.toString(),
        );
      }
      rethrow;
    } finally {
      stopwatch.stop();
      debugPrint('⏱️  Total upload time: ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  Future<Uint8List> _readFileInChunks(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      throw StorageException(
        message: 'Failed to read file',
        error: e.toString(),
      );
    }
  }

  Future<Duration> _uploadWithRetry({
    required String filePath,
    required Uint8List fileBytes,
    required String contentType,
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    StorageException? lastError;
    
    while (attempt <= maxRetries) {
      attempt++;
      final stopwatch = Stopwatch()..start();
      
      try {
        await _supabase.storage
            .from(_bucketName)
            .uploadBinary(
              filePath,
              fileBytes,
              fileOptions: FileOptions(
                contentType: contentType,
                upsert: false,
              ),
            );
            
        return stopwatch.elapsed;
      } catch (e) {
        lastError = StorageException(
          message: 'Upload attempt $attempt failed',
          error: e.toString(),
        );
        debugPrint('⚠️  ${lastError.message}');
        
        if (attempt <= maxRetries) {
          // Exponential backoff: 1s, 2s, 4s, etc.
          final delay = Duration(seconds: 1 << (attempt - 1));
          debugPrint('⏳ Retrying in ${delay.inSeconds}s...');
          await Future<void>.delayed(delay);
        }
      } finally {
        stopwatch.stop();
      }
    }
    
    throw lastError ?? StorageException(message: 'Upload failed after $maxRetries attempts');
  }
  
  String _getPublicUrl(String filePath) {
    try {
      final response = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);
      
      if (response.isEmpty) {
        throw StorageException(message: 'Empty public URL received');
      }
      
      return response;
    } catch (e) {
      throw StorageException(
        message: 'Failed to get public URL',
        error: e.toString(),
      );
    }
  }
  
  String _formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(k)).floor();
    return '${(bytes / pow(k, i)).toStringAsFixed(decimals)} ${sizes[i]}';
  }

  /// Deletes a file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      debugPrint('🗑️  Attempting to delete file: $fileUrl');
      
      // Extract the file path from the URL (remove the domain part)
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      
      // The path should be in the format: /storage/v1/object/public/bucket-name/path/to/file
      // We need to get everything after the bucket name
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
        throw StorageException(
          message: 'Invalid file URL format',
          error: 'Could not extract file path from URL',
        );
      }
      
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      debugPrint('🗑️  Deleting file path: $filePath');
      
      await _supabase.storage
          .from(_bucketName)
          .remove([filePath]);
          
      debugPrint('✅ Successfully deleted file: $filePath');
    } on StorageException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error deleting file:');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      
      throw StorageException(
        message: 'Failed to delete file',
        error: e.toString(),
      );
    }
  }
}

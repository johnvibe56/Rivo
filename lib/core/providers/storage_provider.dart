import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/providers/supabase_provider.dart';
import 'package:rivo/core/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  final supabase = SupabaseService.client;
  return StorageService(supabase);
});

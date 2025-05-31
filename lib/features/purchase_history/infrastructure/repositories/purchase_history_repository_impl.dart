import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/purchase_history/domain/models/purchase_with_product_model.dart';
import 'package:rivo/features/purchase_history/domain/repositories/purchase_history_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseHistoryRepositoryImpl implements PurchaseHistoryRepository {
  final SupabaseClient supabaseClient;

  PurchaseHistoryRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, List<PurchaseWithProduct>>> getPurchaseHistory() async {
    try {
      // Check network connectivity
      final hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return const Left(UnauthorizedFailure('User not authenticated'));
      }

      try {
        // Use the database function to get purchases with product details
        final response = await supabaseClient.rpc<List<dynamic>>(
          'get_purchase_history',
          params: {'p_user_id': userId},
        );

        if (response.isEmpty) {
          return const Right(<PurchaseWithProduct>[]);
        }

        final purchases = response
            .map<PurchaseWithProduct>((json) => PurchaseWithProduct.fromJson(json as Map<String, dynamic>))
            .toList();
            
        return Right(purchases);
      } catch (e) {
        developer.log('Error in getPurchaseHistory: $e', error: e);
        return Left(DataParsingFailure('Failed to parse purchase data: $e'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException {
      return const Left(NetworkFailure('Request timed out'));
    } on SocketException {
      return const Left(NetworkFailure('Network error occurred'));
    } on FormatException {
      return const Left(DataParsingFailure('Invalid data format'));
    } on Exception catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

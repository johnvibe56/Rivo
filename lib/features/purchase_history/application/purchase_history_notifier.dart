import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/purchase_history/domain/models/purchase_with_product_model.dart';
import 'package:rivo/features/purchase_history/domain/repositories/purchase_history_repository.dart';
import 'package:rivo/features/purchase_history/infrastructure/repositories/purchase_history_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'purchase_history_notifier.freezed.dart';
part 'purchase_history_notifier.g.dart';

@freezed
class PurchaseHistoryState with _$PurchaseHistoryState {
  const factory PurchaseHistoryState.initial() = _Initial;
  const factory PurchaseHistoryState.loading() = _Loading;
  const factory PurchaseHistoryState.loaded(List<PurchaseWithProduct> purchases) = _Loaded;
  const factory PurchaseHistoryState.error(Failure failure) = _Error;
}

@riverpod
class PurchaseHistoryNotifier extends _$PurchaseHistoryNotifier {
  @override
  FutureOr<PurchaseHistoryState> build() async {
    // Initial state
    return const PurchaseHistoryState.initial();
  }

  Future<void> fetchPurchases() async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(purchaseHistoryRepositoryNotifierProvider);
    final result = await repository.getPurchaseHistory();
    
    state = result.fold(
      (failure) => AsyncValue.data(PurchaseHistoryState.error(failure)),
      (purchases) => AsyncValue.data(
        purchases.isEmpty 
          ? const PurchaseHistoryState.loaded([])
          : PurchaseHistoryState.loaded(purchases),
      ),
    );
  }
}

@riverpod
class PurchaseHistoryRepositoryNotifier extends _$PurchaseHistoryRepositoryNotifier {
  @override
  PurchaseHistoryRepository build() {
    final supabaseClient = Supabase.instance.client;
    return PurchaseHistoryRepositoryImpl(supabaseClient: supabaseClient);
  }
}

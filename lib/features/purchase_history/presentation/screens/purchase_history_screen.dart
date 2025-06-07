import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/core/presentation/widgets/empty_state_widget.dart';
import 'package:rivo/core/presentation/widgets/error_state_widget.dart';
import 'package:rivo/core/presentation/widgets/loading_widget.dart';
import 'package:rivo/core/utils/date_utils.dart' as date_utils;
import 'package:rivo/features/purchase_history/application/purchase_history_notifier.dart';
import 'package:rivo/features/purchase_history/domain/models/purchase_with_product_model.dart';
import 'package:rivo/features/purchase_history/presentation/widgets/purchase_history_card.dart';
import 'package:rivo/l10n/l10n.dart';
/// Extension to access purchase history localizations
extension PurchaseHistoryLocalizations on BuildContext {
  FallbackLocalizations get l10n => const FallbackLocalizations();
  
  String get purchaseHistoryTitle => l10n.purchaseHistoryTitle;
  String get loadingPurchases => l10n.loadingPurchases;
  String get noPurchasesYet => l10n.noPurchasesYet;
  String get purchasesWillAppearHere => l10n.purchasesWillAppearHere;
  String get signInToViewHistory => l10n.signInToViewHistory;
  String get errorLoadingPurchases => l10n.errorLoadingPurchases;
  String get retry => l10n.retry;
  String get login => l10n.login;
  String get noInternetConnection => l10n.noInternetConnection;
  String get noInternetConnectionMessage => l10n.noInternetConnectionMessage;
  String get serverErrorMessage => l10n.serverErrorMessage;
  String get unexpectedError => l10n.unexpectedError;
  String get unexpectedErrorMessage => l10n.unexpectedErrorMessage;
  String get reportIssue => l10n.reportIssue;
  String get goToLogin => l10n.goToLogin;
}

/// Semantic labels for screen readers
extension PurchaseHistorySemantics on BuildContext {
  String get purchaseListSemanticLabel => 'List of purchases';
  String get loadingPurchasesSemanticLabel => 'Loading purchases';
  String get purchaseItemSemanticLabel => 'Purchase item';
  String get retryButtonSemanticLabel => 'Retry loading purchases';
  String get signInButtonSemanticLabel => 'Sign in to view purchase history';
}

class PurchaseHistoryScreen extends ConsumerStatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  ConsumerState<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends ConsumerState<PurchaseHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch purchases when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseHistoryNotifierProvider.notifier).fetchPurchases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.purchaseHistoryTitle),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final purchaseState = ref.watch(purchaseHistoryNotifierProvider);
          
          return purchaseState.when(
            data: (state) {
              return state.maybeWhen(
                loaded: (purchases) => _buildPurchaseList(purchases),
                error: (failure) => _buildErrorState(failure, ref),
                orElse: () => _buildLoadingState(),
              );
            },
            loading: () => _buildLoadingState(),
            error: (error, stackTrace) => _buildUnexpectedError(error, stackTrace, ref),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Semantics(
      label: context.loadingPurchasesSemanticLabel,
      child: Directionality(
        textDirection: Directionality.of(context),
        child: LoadingWidget(
          message: context.loadingPurchases,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Semantics(
      label: '${context.noPurchasesYet}. ${context.purchasesWillAppearHere}',
      child: Directionality(
        textDirection: Directionality.of(context),
        child: Center(
          child: EmptyStateWidget(
            icon: Icons.shopping_bag_outlined,
            title: context.noPurchasesYet,
            message: context.purchasesWillAppearHere,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Failure failure, WidgetRef ref) {
    if (failure is UnauthorizedFailure) {
      return _buildUnauthorizedState();
    }

    return ErrorStateWidget(
      errorMessage: _getErrorMessage(failure),
      onRetry: () => ref.read(purchaseHistoryNotifierProvider.notifier).fetchPurchases(),
      retryButtonSemanticLabel: context.retryButtonSemanticLabel,
    );
  }

  Widget _buildUnauthorizedState() {
    return Semantics(
      label: context.signInToViewHistory,
      child: Directionality(
        textDirection: Directionality.of(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                excludeSemantics: true,
                child: const Icon(Icons.login, size: 64, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Text(
                context.signInToViewHistory,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: context.signInButtonSemanticLabel,
                child: AppButton.primary(
                  onPressed: () {
                    // TODO: Navigate to login
                  },
                  label: context.login,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnexpectedError(
    Object error,
    StackTrace stackTrace,
    WidgetRef ref,
  ) {
    return ErrorStateWidget(
      errorMessage: context.unexpectedErrorMessage,
      onRetry: () => ref.read(purchaseHistoryNotifierProvider.notifier).fetchPurchases(),
      retryButtonSemanticLabel: context.retryButtonSemanticLabel,
    );
  }

  String _getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return context.serverErrorMessage;
    } else if (failure is NetworkFailure) {
      return context.noInternetConnectionMessage;
    } else if (failure is UnauthorizedFailure) {
      return context.signInToViewHistory;
    } else {
      return '${context.unexpectedErrorMessage}\n${failure.toString()}';
    }
  }

  Widget _buildPurchaseList(List<PurchaseWithProduct> purchases) {
    if (purchases.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(purchaseHistoryNotifierProvider.notifier).fetchPurchases(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          final purchase = purchases[index];
          return Semantics(
            button: true,
            label: '${purchase.product?.name ?? 'Purchase'} - ${date_utils.AppDateUtils.formatPurchaseDate(purchase.createdAt.toLocal(), context)}',
            child: PurchaseHistoryCard(
              key: ValueKey('purchase-${purchase.id}'),
              purchase: purchase,
              onTap: () {
                // TODO: Navigate to purchase details
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

class UploadLoadingWidget extends StatelessWidget {
  final String? message;

  const UploadLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message ?? l10n.uploading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class UploadSuccessWidget extends StatelessWidget {
  final VoidCallback onContinueShopping;
  final VoidCallback onViewProduct;

  const UploadSuccessWidget({
    super.key,
    required this.onContinueShopping,
    required this.onViewProduct,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.uploadSuccessTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.uploadSuccessMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          AppButton.primary(
            onPressed: onViewProduct,
            label: l10n.viewProduct,
            fullWidth: true,
          ),
          const SizedBox(height: 12),
          AppButton.outlined(
            onPressed: onContinueShopping,
            label: l10n.continueShopping,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class UploadErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const UploadErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.uploadErrorTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              AppButton.primary(
                onPressed: onRetry,
                label: l10n.retry,
                fullWidth: true,
              ),
              const SizedBox(height: 12),
              AppButton.outlined(
                onPressed: onCancel,
                label: l10n.cancel,
                fullWidth: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

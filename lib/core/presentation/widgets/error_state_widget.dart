import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/l10n.dart';

class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final String retryButtonSemanticLabel;
  final IconData? icon;
  final String? title;
  final bool showReportButton;
  final VoidCallback? onReportPressed;

  const ErrorStateWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    required this.retryButtonSemanticLabel,
    this.icon,
    this.title,
    this.showReportButton = false,
    this.onReportPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64.w,
              color: theme.colorScheme.error.withOpacity(0.8),
            ),
            SizedBox(height: 16.h),
            if (title != null) ...{
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
            },
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Semantics(
              button: true,
              label: retryButtonSemanticLabel,
              child: AppButton.primary(
                onPressed: onRetry,
                label: context.l10n.retry,
              ),
            ),
            if (showReportButton) ...{
              SizedBox(height: 12.h),
              AppButton.text(
                onPressed: onReportPressed,
                label: context.l10n.reportIssue,
              ),
            },
          ],
        ),
      ),
    );
  }
}

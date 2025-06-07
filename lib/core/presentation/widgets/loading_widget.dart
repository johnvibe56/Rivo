import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rivo/core/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final bool showProgress;
  final double progressSize;
  final double spacing;

  const LoadingWidget({
    Key? key,
    required this.message,
    this.showProgress = true,
    this.progressSize = 32,
    this.spacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showProgress)
            SizedBox(
              width: progressSize.w,
              height: progressSize.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          if (showProgress && message.isNotEmpty) SizedBox(height: spacing.h),
          if (message.isNotEmpty)
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

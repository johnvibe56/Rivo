import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'loading_indicator.dart';
import 'rivo_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customIllustration;
  final EdgeInsets? padding;
  final bool showLoading;
  final String? loadingText;

  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.buttonText,
    this.onButtonPressed,
    this.customIllustration,
    this.padding,
    this.showLoading = false,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showLoading) ...[
              AppLoadingIndicator(
                size: 48.0,
                strokeWidth: 2.0,
                color: iconColor ?? theme.colorScheme.primary,
              ),
              if (loadingText != null) ...[
                const SizedBox(height: 16.0),
                Text(
                  loadingText!,
                  style: textTheme.bodyLarge?.copyWith(
                    // ignore: deprecated_member_use
                    color: textTheme.bodyLarge?.color?.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ] else ...[
              if (customIllustration != null)
                customIllustration!
              else if (icon != null)
                Icon(
                  icon,
                  size: iconSize,
                  // ignore: deprecated_member_use
                  color: iconColor ?? theme.hintColor.withOpacity(0.5),
                ),
              const SizedBox(height: 24.0),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  // ignore: deprecated_member_use
                  color: theme.textTheme.titleLarge?.color?.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                const SizedBox(height: 8.0),
                Text(
                  description!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (buttonText != null && onButtonPressed != null) ...[
                const SizedBox(height: 24.0),
                RivoButton(
                  text: buttonText!,
                  onPressed: onButtonPressed,
                  isExpanded: false,
                  variant: RivoButtonVariant.primary,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // Standard empty state for no items
  factory EmptyState.noItems({
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyState(
      title: 'אין פריטים להצגה',
      description: message ?? 'לא נמצאו פריטים תואמים לחיפוש שלך',
      icon: Icons.inventory_2_outlined,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  // Error state
  factory EmptyState.error({
    String? message,
    String? buttonText,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      title: 'אירעה שגיאה',
      description: message ?? 'לא הצלחנו לטעון את הנתונים. נסו שוב מאוחר יותר.',
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      buttonText: buttonText ?? 'נסה שוב',
      onButtonPressed: onRetry,
    );
  }

  // No internet connection state
  factory EmptyState.noConnection({
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      title: 'אין חיבור אינטרנט',
      description: 'נא בדוק את חיבור האינטרנט שלך ונסה שוב',
      icon: Icons.wifi_off_rounded,
      buttonText: 'נסה שוב',
      onButtonPressed: onRetry,
    );
  }

  // No search results state
  factory EmptyState.noSearchResults({
    String? query,
    VoidCallback? onClearSearch,
  }) {
    return EmptyState(
      title: 'לא נמצאו תוצאות',
      description: query != null
          ? 'לא נמצאו תוצאות עבור "$query"'
          : 'לא נמצאו תוצאות תואמות',
      icon: Icons.search_off_rounded,
      buttonText: 'נקה חיפוש',
      onButtonPressed: onClearSearch,
    );
  }

  // Empty cart state
  factory EmptyState.emptyCart({VoidCallback? onStartShopping}) {
    return EmptyState(
      title: 'הסל שלך ריק',
      description: 'הוסף פריטים לסל כדי לראות אותם כאן',
      icon: Icons.shopping_bag_outlined,
      buttonText: 'התחל בקנייה',
      onButtonPressed: onStartShopping,
    );
  }

  // Empty favorites state
  factory EmptyState.emptyFavorites({VoidCallback? onBrowseProducts}) {
    return EmptyState(
      title: 'אין לך מועדפים עדיין',
      description: 'שמור את הפריטים האהובים עליך כדי למצוא אותם בקלות',
      icon: Icons.favorite_border_rounded,
      buttonText: 'גלה פריטים חדשים',
      onButtonPressed: onBrowseProducts,
    );
  }

  // Empty orders state
  factory EmptyState.emptyOrders({VoidCallback? onStartShopping}) {
    return EmptyState(
      title: 'אין הזמנות עדיין',
      description: 'ההזמנות שלך יופיעו כאן ברגע שתבצע הזמנה',
      icon: Icons.receipt_long_outlined,
      buttonText: 'התחל בקנייה',
      onButtonPressed: onStartShopping,
    );
  }

  // Loading state
  factory EmptyState.loading({String? message}) {
    return EmptyState(
      title: 'טוען...',
      showLoading: true,
      loadingText: message,
    );
  }

  // Custom empty state
  factory EmptyState.custom({
    required String title,
    String? description,
    Widget? customIllustration,
    IconData? icon,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyState(
      title: title,
      description: description,
      customIllustration: customIllustration,
      icon: icon,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }
}

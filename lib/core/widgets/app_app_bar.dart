import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'rivo_button.dart' show RivoButtonVariant;
import 'rivo_icon_button.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? titleSpacing;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;
  final double leadingWidth;
  final bool automaticallyImplyLeading;

  const AppAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.titleColor,
    this.titleSpacing,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
    this.leadingWidth = 56.0,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: titleColor ?? theme.textTheme.titleLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading ??
          (showBackButton
              ? RivoIconButton(
                  icon: isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  onPressed: () => Navigator.of(context).maybePop(),
                  size: 40.0,
                  iconSize: 20.0,
                  variant: RivoButtonVariant.text,
                )
              : null),
      leadingWidth: leadingWidth,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      elevation: elevation,
      titleSpacing: titleSpacing,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppDimens.radiusL),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  // Factory constructor for search app bar
  factory AppAppBar.search({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required VoidCallback onBackPressed,
    String hintText = 'חפש פריטים, מותגים וקטגוריות',
    List<Widget>? actions,
  }) {
    return AppAppBar(
      title: '',
      showBackButton: false,
      leading: RivoIconButton(
        icon: Icons.arrow_forward_ios,
        onPressed: onBackPressed,
        size: 40.0,
        iconSize: 20.0,
        variant: RivoButtonVariant.text,
      ),
      actions: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 24),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        ...(actions ?? []),
      ],
    );
  }

  // Factory constructor for filter app bar
  factory AppAppBar.withFilters({
    required String title,
    required VoidCallback onFilterPressed,
    required VoidCallback onSortPressed,
    bool showBackButton = true,
    List<Widget>? actions,
  }) {
    return AppAppBar(
      title: title,
      showBackButton: showBackButton,
      actions: [
        RivoIconButton(
          icon: Icons.sort,
          onPressed: onSortPressed,
          size: 40.0,
          iconSize: 24.0,
          variant: RivoButtonVariant.text,
        ),
        const SizedBox(width: 8),
        Stack(
          alignment: Alignment.topRight,
          children: [
            RivoIconButton(
              icon: Icons.filter_list,
              onPressed: onFilterPressed,
              size: 40.0,
              iconSize: 24.0,
              color: Colors.white,
              variant: RivoButtonVariant.text,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        ...(actions ?? []),
      ],
    );
  }
}

// A custom app bar with a transparent background
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? iconColor;
  final double elevation;
  final double toolbarHeight;

  const TransparentAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.iconColor,
    this.elevation = 0,
    this.toolbarHeight = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      centerTitle: true,
      leading: leading ??
          (showBackButton
              ? RivoIconButton(
                  icon: isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  onPressed: () => Navigator.of(context).maybePop(),
                  color: iconColor ?? Colors.white,
                  size: 40.0,
                  iconSize: 20.0,
                  variant: RivoButtonVariant.text,
                )
              : null),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: elevation,
      iconTheme: IconThemeData(
        color: iconColor ?? Colors.white,
      ),
      toolbarHeight: toolbarHeight,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}

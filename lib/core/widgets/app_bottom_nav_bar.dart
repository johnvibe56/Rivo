import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_dimens.dart';

class BottomNavItem {
  final IconData icon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class AppBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double iconSize;
  final double itemPadding;
  final bool showLabels;
  final double elevation;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.iconSize = 24.0,
    this.itemPadding = 8.0,
    this.showLabels = true,
    this.elevation = 8.0,
  }) : assert(items.length >= 2 && items.length <= 5, 'Bottom navigation bar must have between 2 and 5 items');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusL)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor ?? Colors.white,
          selectedItemColor: selectedItemColor ?? theme.bottomNavigationBarTheme.selectedItemColor ?? theme.colorScheme.primary,
          unselectedItemColor: unselectedItemColor ?? theme.bottomNavigationBarTheme.unselectedItemColor ?? theme.hintColor,
          selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle ??
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
          unselectedLabelStyle: theme.bottomNavigationBarTheme.unselectedLabelStyle ??
              TextStyle(
                fontSize: 12,
                height: 1.5,
              ),
          iconSize: iconSize,
          elevation: elevation,
          showSelectedLabels: showLabels,
          showUnselectedLabels: showLabels,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: items.map((item) {
            return BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: itemPadding),
                child: Icon(item.icon, size: iconSize),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  // Predefined bottom navigation items
  static List<BottomNavItem> get defaultItems => [
        BottomNavItem(
          icon: Icons.home_outlined,
          label: 'בית',
          route: '/home',
        ),
        BottomNavItem(
          icon: Icons.search,
          label: 'גלה',
          route: '/explore',
        ),
        BottomNavItem(
          icon: Icons.add_circle_outline,
          label: 'העלאה',
          route: '/upload',
        ),
        BottomNavItem(
          icon: Icons.favorite_border,
          label: 'מועדפים',
          route: '/favorites',
        ),
        BottomNavItem(
          icon: Icons.person_outline,
          label: 'אני',
          route: '/profile',
        ),
      ];

  // Bottom navigation bar with a floating action button in the middle
  static Widget withFloatingActionButton({
    required BuildContext context,
    required int currentIndex,
    required ValueChanged<int> onTap,
    required VoidCallback onFloatingActionButtonPressed,
    IconData? floatingActionButtonIcon,
    String? floatingActionButtonTooltip,
    Color? floatingActionButtonBackgroundColor,
    Color? floatingActionButtonForegroundColor,
    double? floatingActionButtonElevation,
    List<BottomNavItem>? items,
  }) {
    final theme = Theme.of(context);
    final navItems = items ?? defaultItems;

    return Stack(
      children: [
        Positioned.fill(
          child: AppBottomNavBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: navItems,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).padding.bottom + 8,
          child: Center(
            child: FloatingActionButton(
              onPressed: onFloatingActionButtonPressed,
              tooltip: floatingActionButtonTooltip ?? 'הוסף פריט חדש',
              backgroundColor: floatingActionButtonBackgroundColor ?? theme.colorScheme.primary,
              foregroundColor: floatingActionButtonForegroundColor ?? theme.colorScheme.onPrimary,
              elevation: floatingActionButtonElevation ?? 4.0,
              child: Icon(floatingActionButtonIcon ?? Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

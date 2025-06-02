import 'package:flutter/material.dart';

class AppTabBar extends StatelessWidget {
  final TabController? controller;
  final List<Widget> tabs;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final Color? indicatorColor;
  final double indicatorWeight;
  final EdgeInsetsGeometry? indicatorPadding;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final TabBarIndicatorSize? indicatorSize;
  final ValueChanged<int>? onTap;

  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = false,
    this.padding,
    this.indicatorColor,
    this.indicatorWeight = 2.0,
    this.indicatorPadding,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.indicatorSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            // ignore: deprecated_member_use
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        isScrollable: isScrollable,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
        indicatorColor: indicatorColor ?? theme.colorScheme.primary,
        indicatorWeight: indicatorWeight,
        indicatorPadding: indicatorPadding ?? const EdgeInsets.symmetric(horizontal: 8.0),
        indicatorSize: indicatorSize ?? TabBarIndicatorSize.tab,
        labelColor: labelColor ?? theme.colorScheme.primary,
        unselectedLabelColor: unselectedLabelColor ?? theme.hintColor,
        labelStyle: labelStyle ?? theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: unselectedLabelStyle ?? theme.textTheme.labelLarge,
        onTap: onTap,
      ),
    );
  }

  // Factory constructor for text-only tabs
  factory AppTabBar.text({
    required TabController controller,
    required List<String> tabLabels,
    bool isScrollable = false,
    ValueChanged<int>? onTap,
  }) {
    return AppTabBar(
      controller: controller,
      tabs: tabLabels.map((label) => Tab(text: label)).toList(),
      isScrollable: isScrollable,
      onTap: onTap,
    );
  }

  // Factory constructor for icon-only tabs
  factory AppTabBar.icons({
    required TabController controller,
    required List<IconData> tabIcons,
    bool isScrollable = false,
    ValueChanged<int>? onTap,
  }) {
    return AppTabBar(
      controller: controller,
      tabs: tabIcons.map((icon) => Tab(icon: Icon(icon))).toList(),
      isScrollable: isScrollable,
      onTap: onTap,
    );
  }

  // Factory constructor for icon with label tabs
  factory AppTabBar.iconWithLabel({
    required TabController controller,
    required List<MapEntry<IconData, String>> tabItems,
    bool isScrollable = false,
    ValueChanged<int>? onTap,
  }) {
    return AppTabBar(
      controller: controller,
      tabs: tabItems.map((item) => Tab(
        icon: Icon(item.key),
        text: item.value,
      )).toList(),
      isScrollable: isScrollable,
      onTap: onTap,
    );
  }
}

// A tab bar with a custom indicator that's centered and has a fixed width
class CenteredTabBar extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;
  final double indicatorWidth;
  final Color? indicatorColor;
  final double indicatorHeight;
  final double indicatorBottomPadding;
  final bool isScrollable;
  final EdgeInsets? padding;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final ValueChanged<int>? onTap;

  const CenteredTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.indicatorWidth = 24.0,
    this.indicatorColor,
    this.indicatorHeight = 3.0,
    this.indicatorBottomPadding = 8.0,
    this.isScrollable = false,
    this.padding,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        TabBar(
          controller: controller,
          tabs: tabs,
          isScrollable: isScrollable,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: indicatorHeight,
              color: indicatorColor ?? theme.colorScheme.primary,
            ),
            insets: EdgeInsets.only(
              bottom: indicatorBottomPadding,
              left: (MediaQuery.of(context).size.width / tabs.length - indicatorWidth) / 2,
              right: (MediaQuery.of(context).size.width / tabs.length - indicatorWidth) / 2,
            ),
          ),
          labelColor: labelColor ?? theme.colorScheme.primary,
          unselectedLabelColor: unselectedLabelColor ?? theme.hintColor,
          labelStyle: labelStyle ?? theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: unselectedLabelStyle ?? theme.textTheme.labelLarge,
          onTap: onTap,
          labelPadding: EdgeInsets.zero,
        ),
        Container(
          height: 1.0,
          // ignore: deprecated_member_use
          color: theme.dividerColor.withOpacity(0.1),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// A utility class for handling scroll-based animations and behaviors
class ScrollUtils {
  /// Creates a scroll controller that notifies when the user has scrolled
  /// to the bottom of the list
  static ScrollController createScrollController({
    required VoidCallback onEndReached,
    double threshold = 0.8,
  }) {
    final controller = ScrollController();
    
    controller.addListener(() {
      final maxScroll = controller.position.maxScrollExtent;
      final currentScroll = controller.offset;
      final scrollThreshold = maxScroll * threshold;
      
      if (currentScroll >= scrollThreshold) {
        onEndReached();
      }
    });
    
    return controller;
  }
  
  /// Creates a scroll controller that triggers a callback when the user
  /// scrolls near the bottom of the list (for infinite scroll)
  static ScrollController createInfiniteScrollController({
    required Future<void> Function() onLoadMore,
    double loadMoreThreshold = 0.8,
  }) {
    final controller = ScrollController();
    bool isLoadingMore = false;
    
    void handleScroll() {
      if (isLoadingMore) return;
      
      final maxScroll = controller.position.maxScrollExtent;
      final currentScroll = controller.position.pixels;
      final thresholdReached = currentScroll >= (maxScroll * loadMoreThreshold);
      
      if (thresholdReached && controller.position.outOfRange) {
        isLoadingMore = true;
        
        onLoadMore().whenComplete(() {
          isLoadingMore = false;
        });
      }
    }
    
    controller.addListener(handleScroll);
    
    return controller;
  }
  
  /// Creates a scroll controller that triggers callbacks for various scroll positions
  static ScrollController createSmartScrollController({
    VoidCallback? onScrollStart,
    VoidCallback? onScrollEnd,
    ValueChanged<double>? onScrollUpdate,
    VoidCallback? onReachTop,
    VoidCallback? onReachBottom,
    double topThreshold = 0.0,
    double bottomThreshold = 0.8,
  }) {
    final controller = ScrollController();
    bool isScrolling = false;
    
    controller.addListener(() {
      // Notify scroll update
      onScrollUpdate?.call(controller.offset);
      
      // Check if we've reached the top
      if (controller.offset <= topThreshold && onReachTop != null) {
        onReachTop();
      }
      
      // Check if we've reached the bottom
      final maxScroll = controller.position.maxScrollExtent;
      if (controller.offset >= (maxScroll * bottomThreshold) && onReachBottom != null) {
        onReachBottom();
      }
      
      // Handle scroll start/end
      if (controller.position.isScrollingNotifier.value) {
        if (!isScrolling) {
          isScrolling = true;
          onScrollStart?.call();
        }
      } else if (isScrolling) {
        isScrolling = false;
        onScrollEnd?.call();
      }
    });
    
    return controller;
  }
  
  /// Animate to a specific position in the scroll view
  static Future<void> animateToPosition(
    ScrollController controller, {
    required double offset,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (controller.hasClients) {
      await controller.animateTo(
        offset,
        duration: duration,
        curve: curve,
      );
    }
  }
  
  /// Animate to the top of the scroll view
  static Future<void> animateToTop(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    await animateToPosition(
      controller,
      offset: 0,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Animate to the bottom of the scroll view
  static Future<void> animateToBottom(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (controller.hasClients) {
      await animateToPosition(
        controller,
        offset: controller.position.maxScrollExtent,
        duration: duration,
        curve: curve,
      );
    }
  }
  
  /// Check if the scroll view is at the bottom
  static bool isAtBottom(ScrollController controller) {
    if (!controller.hasClients) return false;
    
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.offset;
    
    return currentScroll >= (maxScroll * 0.9);
  }
  
  /// Check if the scroll view is at the top
  static bool isAtTop(ScrollController controller) {
    if (!controller.hasClients) return true;
    return controller.offset <= controller.position.minScrollExtent;
  }
  
  /// Creates a scroll behavior that matches the platform
  static ScrollBehavior platformAwareScrollBehavior() {
    return const MaterialScrollBehavior().copyWith(
      dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/navigation/app_navigation.dart';

/// A screen that redirects to the user's profile screen.
/// This is kept for backward compatibility with existing routes.
class SellerProfileScreen extends ConsumerWidget {
  final String sellerId;
  final String? displayName;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
    this.displayName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Redirect to the new user profile screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use a slight delay to avoid any potential navigation conflicts
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          AppNavigation.goToUserProfile(context, sellerId);
        }
      });
    });

    // Show a loading indicator while redirecting
    return Scaffold(
      appBar: AppBar(
        title: Text(displayName ?? 'Profile'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

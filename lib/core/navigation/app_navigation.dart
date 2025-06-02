import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centralized navigation helper methods
class AppNavigation {
  // Prevent instantiation
  AppNavigation._();

  // Navigation helper methods
  static void goToProductDetail(BuildContext context, String productId) {
    context.go('/product/$productId');
  }

  static void goToSellerProfile(
    BuildContext context, {
    required String sellerId,
    String? displayName,
  }) {
    context.go('/seller/$sellerId');
  }

  static void goToEditProfile(BuildContext context) {
    context.go('/edit-profile');
  }

  static void goToUserProfile(BuildContext context, [String? userId]) {
    if (userId != null) {
      context.go('/user/$userId');
    } else {
      context.go('/user_profile');
    }
  }

  static void goToLogin(BuildContext context) {
    context.go('/login');
  }

  static void goToSignup(BuildContext context) {
    context.go('/signup');
  }

  static void goToForgotPassword(BuildContext context) {
    context.go('/forgot-password');
  }

  static void goToFeed(BuildContext context) {
    context.go('/feed');
  }

  static void goToProducts(BuildContext context) {
    context.go('/products');
  }

  static void goToWishlist(BuildContext context) {
    context.go('/wishlist');
  }

  static void goToCart(BuildContext context) {
    context.go('/cart');
  }

  static void goToPurchaseHistory(BuildContext context) {
    context.go('/purchases');
  }

  static void goToProductUpload(BuildContext context) {
    context.go('/upload-product');
  }
}

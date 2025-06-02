/// Centralized route names and paths for the application
class AppRoutes {
  // Auth routes
  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgot_password';
  static const String onboarding = 'onboarding';
  
  // User profile routes
  static const String userProfile = 'user-profile';
  static const String userProfileById = 'user-profile-by-id';
  static const String sellerProfile = 'seller';
  static const String editProfile = 'edit-profile';
  
  // Main app routes - protected
  static const String feed = 'feed';
  static const String productFeed = 'product_feed';
  static const String productDetail = 'product_detail';
  static const String productUpload = 'product_upload';
  static const String profile = 'user_profile';
  static const String wishlist = 'wishlist';
  static const String cart = 'cart';
  static const String purchaseHistory = 'purchase_history';
  static const String seller = 'seller_profile';
  
  // Helper to get the full path for a route
  static String getPath(String routeName, {Map<String, String>? params}) {
    switch (routeName) {
      case splash:
        return '/splash';
      case login:
        return '/login';
      case signup:
        return '/signup';
      case forgotPassword:
        return '/forgot-password';
      case onboarding:
        return '/onboarding';
      case feed:
        return '/feed';
      case productFeed:
        return '/products';
      case productDetail:
        return '/product/${params?['id'] ?? ':id'}';
      case profile:
        return '/user_profile';
      case userProfileById:
        return '/user/${params?['userId'] ?? ':userId'}';
      case productUpload:
        return '/upload-product';
      case wishlist:
        return '/wishlist';
      case cart:
        return '/cart';
      case sellerProfile:
        return '/seller/${params?['sellerId'] ?? ':sellerId'}';
      case editProfile:
        return '/edit-profile';
      case purchaseHistory:
        return '/purchases';
      default:
        return '/';
    }
  }
}

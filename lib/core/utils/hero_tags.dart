class HeroTags {
  // Product related hero tags
  static String productImage(String productId) => 'product-image-$productId';
  static String productTitle(String productId) => 'product-title-$productId';
  static String productPrice(String productId) => 'product-price-$productId';
  
  // User related hero tags
  static String userAvatar(String userId) => 'user-avatar-$userId';
  static String userName(String userId) => 'user-name-$userId';
  
  // Category related hero tags
  static String categoryImage(String categoryId) => 'category-image-$categoryId';
  static String categoryTitle(String categoryId) => 'category-title-$categoryId';
  
  // Cart related hero tags
  static String cartItemImage(String itemId) => 'cart-item-image-$itemId';
  
  // Wishlist related hero tags
  static String wishlistItemImage(String itemId) => 'wishlist-item-image-$itemId';
  
  // Order related hero tags
  static String orderImage(String orderId, int index) => 'order-$orderId-image-$index';
  
  // Profile related hero tags
  static String profileAvatar(String userId) => 'profile-avatar-$userId';
  static String profileCover(String userId) => 'profile-cover-$userId';
  
  // Search related hero tags
  static String searchBar() => 'search-bar';
  
  // Navigation related hero tags
  static String bottomNavBar() => 'bottom-nav-bar';
  
  // Create a unique hero tag with a custom prefix and id
  static String custom(String prefix, String id) => '$prefix-$id';
  
  // Create a unique hero tag with a timestamp
  static String unique(String prefix) => '$prefix-${DateTime.now().millisecondsSinceEpoch}';
}

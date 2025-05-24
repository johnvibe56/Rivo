import 'package:rivo/features/products/domain/models/product_model.dart';

class ProductUtils {
  // Check if a product is liked by a specific user
  static bool isLikedByUser(Product product, String? userId) {
    if (userId == null) return false;
    return product.likedBy.contains(userId);
  }

  // Check if a product is saved by a specific user
  static bool isSavedByUser(Product product, String? userId) {
    if (userId == null) return false;
    return product.savedBy.contains(userId);
  }

  // Get the number of likes for a product
  static int likeCount(Product product) {
    return product.likedBy.length;
  }

  // Get the number of saves for a product
  static int saveCount(Product product) {
    return product.savedBy.length;
  }

  // Check if the current user is the owner of the product
  static bool isOwner(Product product, String? userId) {
    return product.ownerId == userId;
  }

  // Format price with currency symbol
  static String formatPrice(double price, {String currency = '\$'}) {
    return '$currency${price.toStringAsFixed(2)}';
  }

  // Get a short description (first 100 characters)
  static String getShortDescription(String? description) {
    if (description == null || description.isEmpty) return '';
    return description.length > 100 
        ? '${description.substring(0, 100)}...' 
        : description;
  }
}

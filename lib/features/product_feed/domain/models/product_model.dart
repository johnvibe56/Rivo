class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final int quantity;
  final double discountPercentage;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final String sellerAvatar;
  final DateTime createdAt;
  final bool isNew;
  final bool isPopular;
  final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.quantity = 1,
    this.discountPercentage = 0.0,
    List<String>? imageUrls,
    this.sellerId = '',
    this.sellerName = '',
    this.sellerAvatar = '',
    DateTime? createdAt,
    this.isNew = false,
    this.isPopular = false,
    List<String>? tags,
  })  : imageUrls = imageUrls ?? [imageUrl],
        createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

  // Calculate the final price after discount
  double get finalPrice {
    if (discountPercentage > 0) {
      return price * (1 - discountPercentage / 100);
    }
    return price;
  }

  bool get inStock => quantity > 0;
  bool get onSale => discountPercentage > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'discountPercentage': discountPercentage,
      'quantity': quantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      discountPercentage: (map['discountPercentage'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      description: map['description'] ?? '',
    );
  }
}

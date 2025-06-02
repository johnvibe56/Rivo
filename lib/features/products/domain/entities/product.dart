class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final bool isOnlyOne;
  final String? sellerId;
  final String? sellerName;
  final String? sellerAvatar;
  final String category;
  final String condition;
  final String? brand;
  final String? size;
  final String? color;
  final List<String>? tags;
  final DateTime createdAt;
  final bool isSold;
  final double? originalPrice;
  final double? discountPercentage;
  final double? rating;
  final int? reviewCount;
  final Map<String, dynamic>? details;
  final bool isLiked;

  factory Product({
    required String id,
    required String title,
    required String description,
    required double price,
    required List<String> images,
    bool isOnlyOne = false,
    String? sellerId,
    String? sellerName,
    String? sellerAvatar,
    String category = 'אחר',
    String condition = 'מצוין',
    String? brand,
    String? size,
    String? color,
    List<String>? tags,
    DateTime? createdAt,
    bool isSold = false,
    double? originalPrice,
    double? discountPercentage,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? details,
    bool isLiked = false,
  }) {
    return Product._(
      id: id,
      title: title,
      description: description,
      price: price,
      images: images,
      isOnlyOne: isOnlyOne,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      category: category,
      condition: condition,
      brand: brand,
      size: size,
      color: color,
      tags: tags,
      createdAt: createdAt,
      isSold: isSold,
      originalPrice: originalPrice,
      discountPercentage: discountPercentage,
      rating: rating,
      reviewCount: reviewCount,
      details: details,
      isLiked: isLiked,
    );
  }

  Product._({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    this.isOnlyOne = false,
    this.sellerId,
    this.sellerName,
    this.sellerAvatar,
    this.category = 'אחר',
    this.condition = 'מצוין',
    this.brand,
    this.size,
    this.color,
    this.tags,
    DateTime? createdAt,
    this.isSold = false,
    this.originalPrice,
    this.discountPercentage,
    this.rating,
    this.reviewCount,
    this.details,
    this.isLiked = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Copy with method to create a new instance with some changed fields
  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    List<String>? images,
    bool? isOnlyOne,
    String? sellerId,
    String? sellerName,
    String? sellerAvatar,
    String? category,
    String? condition,
    String? brand,
    String? size,
    String? color,
    List<String>? tags,
    DateTime? createdAt,
    bool? isSold,
    double? originalPrice,
    double? discountPercentage,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? details,
    bool? isLiked,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      isOnlyOne: isOnlyOne ?? this.isOnlyOne,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isSold: isSold ?? this.isSold,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      details: details ?? this.details,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'isOnlyOne': isOnlyOne,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAvatar': sellerAvatar,
      'category': category,
      'condition': condition,
      'brand': brand,
      'size': size,
      'color': color,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'isSold': isSold,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'reviewCount': reviewCount,
      'details': details,
      'isLiked': isLiked,
    };
  }

  // Create from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] as List<dynamic>),
      isOnlyOne: json['isOnlyOne'] as bool? ?? false,
      sellerId: json['sellerId'] as String?,
      sellerName: json['sellerName'] as String?,
      sellerAvatar: json['sellerAvatar'] as String?,
      category: json['category'] as String? ?? 'אחר',
      condition: json['condition'] as String? ?? 'מצוין',
      brand: json['brand'] as String?,
      size: json['size'] as String?,
      color: json['color'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List<dynamic>) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      isSold: json['isSold'] as bool? ?? false,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      details: json['details'] as Map<String, dynamic>?,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  // Create a sample product for testing
  factory Product.sample() {
    return Product(
      id: '1',
      title: 'שמלה וינטג׳ית פרחונית',
      description: 'שמלה וינטג׳ית יפייפיה מבד נושם, מידה M',
      price: 129.90,
      images: [
        'https://example.com/dress1.jpg',
      ],
      isOnlyOne: true,
      sellerId: 'user123',
      sellerName: 'מיכל לוי',
      sellerAvatar: 'https://example.com/avatar1.jpg',
      category: 'שמלות',
      condition: 'מעולה',
      brand: 'Zara',
      size: 'M',
      color: 'ורוד',
      tags: ['וינטג׳', 'פרחוני', 'קיצי'],
      isLiked: false,
    );
  }

  // Check if product is on sale
  bool get isOnSale => originalPrice != null && originalPrice! > price;

  // Calculate discount percentage
  double get calculatedDiscountPercentage {
    if (originalPrice == null || originalPrice! <= 0) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }
}

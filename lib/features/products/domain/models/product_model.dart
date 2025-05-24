class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> likedBy;
  final List<String> savedBy;
  final String ownerId;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.likedBy,
    required this.savedBy,
    required this.ownerId,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      likedBy: List<String>.from(json['liked_by'] as List<dynamic>? ?? []),
      savedBy: List<String>.from(json['saved_by'] as List<dynamic>? ?? []),
      ownerId: json['owner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'liked_by': likedBy,
      'saved_by': savedBy,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.mock() {
    final now = DateTime.now();
    final random = now.millisecondsSinceEpoch % 10;
    final titles = [
      'Vintage Denim Jacket',
      'Wireless Headphones',
      'Leather Wallet',
      'Smart Watch',
      'Running Shoes',
      'Designer Sunglasses',
      'Laptop Backpack',
      'Coffee Maker',
      'Yoga Mat',
      'Bluetooth Speaker'
    ];

    return Product(
      id: 'product_$random',
      title: titles[random],
      description: 'High quality ${titles[random].toLowerCase()}. In excellent condition.',
      price: 10.0 + (random * 10.0),
      imageUrl: 'https://picsum.photos/500/800?random=$random',
      likedBy: [],
      savedBy: [],
      ownerId: 'user_$random',
      createdAt: now.subtract(Duration(days: random)),
    );
  }
}

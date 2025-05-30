import 'dart:convert';
import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> likedBy;
  final List<String> savedBy;
  final String ownerId;
  final String ownerName;
  final String? status;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.likedBy,
    required this.savedBy,
    required this.ownerId,
    this.ownerName = '',
    this.status = 'available',
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Product.fromJson - Raw JSON: $json');
      print('Product.fromJson - Status field: ${json['status']} (type: ${json['status']?.runtimeType})');
    }
    // Helper function to parse liked_by/saved_by fields which might be String or List
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return List<String>.from(value);
      } else if (value is String) {
        try {
          // Try to parse the string as JSON array
          final parsed = List<dynamic>.from(jsonDecode(value));
          return List<String>.from(parsed);
        } catch (e) {
          // If parsing fails, treat it as a single value array
          return [value.toString()];
        }
      }
      return [];
    }

    // Handle profiles join if it exists
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final ownerName = profiles?['username'] as String? ?? 
                     json['owner_name'] as String? ?? 
                     '';

    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      likedBy: parseStringList(json['liked_by']),
      savedBy: parseStringList(json['saved_by']),
      ownerId: json['owner_id'] as String? ?? '',
      ownerName: ownerName,
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
      'owner_name': ownerName,
      'status': status,
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
      ownerName: 'User $random', // This sets a default owner name
      createdAt: now.subtract(Duration(days: random)),
    );
  }
}

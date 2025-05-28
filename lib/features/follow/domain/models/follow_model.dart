import 'package:equatable/equatable.dart';

class Follow extends Equatable {
  final String followerId;
  final String sellerId;
  final DateTime createdAt;

  const Follow({
    required this.followerId,
    required this.sellerId,
    required this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      followerId: json['follower_id'] as String,
      sellerId: json['seller_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'follower_id': followerId,
      'seller_id': sellerId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [followerId, sellerId, createdAt];
}

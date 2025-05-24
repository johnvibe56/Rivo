class FeedPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final DateTime createdAt;

  FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    required this.createdAt,
  });

  factory FeedPost.mock() {
    final now = DateTime.now();
    final random = now.millisecondsSinceEpoch % 10;
    
    return FeedPost(
      id: 'post_${now.millisecondsSinceEpoch}',
      userId: 'user_$random',
      userName: 'User $random',
      userAvatar: 'https://i.pravatar.cc/150?u=user_$random',
      content: 'This is a sample post content. ' * (random % 3 + 1),
      imageUrl: random % 2 == 0 ? 'https://picsum.photos/500/300?random=$random' : null,
      likes: random * 3,
      comments: random * 2,
      createdAt: now.subtract(Duration(hours: random)),
    );
  }

  FeedPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    String? imageUrl,
    int? likes,
    int? comments,
    DateTime? createdAt,
  }) {
    return FeedPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

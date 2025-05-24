import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rivo/features/feed/domain/models/feed_post.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  final FeedPost post;
  final bool isFullScreen;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  
  const PostCard({
    super.key,
    required this.post,
    this.isFullScreen = false,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late VideoPlayerController _videoController;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    // In a real app, you would use the video URL from the post
    // For now, we'll use a placeholder video or image
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'),
    )..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.play();
        _isPlaying = true;
      });
    
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying ? _videoController.pause() : _videoController.play();
      _isPlaying = !_isPlaying;
      _showControls = true;
      _startHideControlsTimer();
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    Widget content = Stack(
      fit: StackFit.expand,
      children: [
        // Background with blur effect
        Container(
          color: Colors.black,
          child: _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : CachedNetworkImage(
                  imageUrl: widget.post.imageUrl ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
        ),
        
        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: size.height * 0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color(0xCC000000), // Black with 0.8 opacity
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        
        // Content overlay
        if (_showControls || !_isPlaying)
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar
                  Container(
                    padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // For You / Following tabs would go here
                      ],
                    ),
                  ),
                  
                  // Spacer to push content to bottom
                  const Spacer(),
                  
                  // Bottom content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: CachedNetworkImageProvider(
                                widget.post.userAvatar,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.post.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Post content
                        Text(
                          widget.post.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Music/song info
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.music_note, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Original Sound - ${widget.post.userName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Right side action buttons
        if (widget.isFullScreen)
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                // Like button
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 32, color: Colors.white),
                      onPressed: widget.onLike,
                    ),
                    Text(
                      '${widget.post.likes}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Comment button
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment_outlined, size: 32, color: Colors.white),
                      onPressed: widget.onComment,
                    ),
                    Text(
                      '${widget.post.comments}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Share button
                IconButton(
                  icon: const Icon(Icons.share, size: 28, color: Colors.white),
                  onPressed: widget.onShare,
                ),
                const SizedBox(height: 20),
                // More options
                const Icon(Icons.more_vert, size: 28, color: Colors.white),
                const SizedBox(height: 20),
                // User avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(widget.post.userAvatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    
    if (widget.isFullScreen) {
      return content;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: content,
    );
  }
}

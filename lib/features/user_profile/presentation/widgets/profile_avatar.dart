import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rivo/core/constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool isEditable;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.isEditable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        backgroundImage: _getImageProvider(),
        child: _buildChild(),
      ),
    );
  }

  ImageProvider? _getImageProvider() {
    if (imageUrl == null) return null;
    
    if (imageUrl!.startsWith('http')) {
      return CachedNetworkImageProvider(
        imageUrl!,
        errorListener: (err) => debugPrint('Image load error: $err'),
      );
    } else if (imageUrl!.startsWith('/')) {
      return FileImage(File(imageUrl!));
    }
    
    return null;
  }

  Widget? _buildChild() {
    if (imageUrl != null) return null;
    
    return Icon(
      Icons.person,
      size: radius,
      color: AppColors.primary,
    );
  }
}

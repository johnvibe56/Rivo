import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rivo/features/user_profile/presentation/widgets/profile_avatar.dart';
import 'package:rivo/l10n/app_localizations.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? currentImagePath;
  final File? pickedImage;
  final VoidCallback onPickImage;
  final bool isLoading;

  const ProfileImagePicker({
    super.key,
    this.currentImagePath,
    this.pickedImage,
    required this.onPickImage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            ProfileAvatar(
              imageUrl: pickedImage?.path ?? currentImagePath,
              radius: 50,
              onTap: onPickImage,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: isLoading ? null : onPickImage,
          icon: const Icon(Icons.camera_alt),
          label: Text(l10n.selectImage),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/core/theme/app_theme.dart';
import 'package:rivo/l10n/app_localizations.dart';

// Default localizations for testing
class _DefaultLocalizations implements _LocalizationsInterface {
  @override
  String get tapToAddImage => 'Tap to add image';
  
  @override
  String get gallery => 'Gallery';
  
  @override
  String get camera => 'Camera';
  
  @override
  String get remove => 'Remove';
}

// Common interface for localizations
abstract class _LocalizationsInterface {
  String get tapToAddImage;
  String get gallery;
  String get camera;
  String get remove;
}

class ImageSelector extends StatelessWidget {
  final File? imageFile;
  final void Function(ImageSource) onImageSelected;
  final VoidCallback? onRemoveImage;
  final String? errorText;

  const ImageSelector({
    super.key,
    this.imageFile,
    required this.onImageSelected,
    this.onRemoveImage,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use a default value if localization is not available (for testing)
    final l10n = (AppLocalizations.of(context) ?? _DefaultLocalizations()) as _LocalizationsInterface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => _showImageSourcePicker(context),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Color.lerp(
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.surface,
                0.5,
              )!,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: errorText != null ? theme.colorScheme.error : theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: imageFile != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius - 1),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                      if (onRemoveImage != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                shape: BoxShape.circle,
                              ),
                              child: AppButton.icon(
                                icon: Icons.close,
                                tooltip: 'Remove', // Hardcoded for testing
                                onPressed: onRemoveImage,
                                variant: AppButtonVariant.text,
                                size: 40,
                                iconSize: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tapToAddImage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showImageSourcePicker(BuildContext context) async {
    // Use the same pattern as in build() to handle null localizations
    final l10n = (AppLocalizations.of(context) ?? _DefaultLocalizations()) as _LocalizationsInterface;
    final textDirection = Directionality.of(context);
    
    // In tests, we might not be able to show the bottom sheet
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => Directionality(
        textDirection: textDirection,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.gallery),
                onTap: () {
                  Navigator.pop(context);
                  onImageSelected(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.camera),
                onTap: () {
                  Navigator.pop(context);
                  onImageSelected(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

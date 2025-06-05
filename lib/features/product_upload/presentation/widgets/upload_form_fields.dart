import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/features/product_upload/domain/validators/product_form_validator.dart';
import 'package:rivo/features/product_upload/presentation/widgets/image_selector.dart';
import 'package:rivo/l10n/app_localizations.dart';

class UploadFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final File? imageFile;
  final bool isSubmitting;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onPriceChanged;
  final VoidCallback onImageRemoved;
  final void Function(ImageSource) onImageSelected;

  const UploadFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.imageFile,
    required this.isSubmitting,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onPriceChanged,
    required this.onImageRemoved,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = Directionality.of(context);
    
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Selector
          Directionality(
            textDirection: textDirection,
            child: ImageSelector(
              imageFile: imageFile,
              onImageSelected: onImageSelected,
              onRemoveImage: imageFile != null ? onImageRemoved : null,
              errorText: isSubmitting
                  ? ProductFormValidator.validateImage(imageFile, context)
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          // Title Field
          Directionality(
            textDirection: textDirection,
            child: TextFormField(
              controller: titleController,
              textDirection: textDirection,
              decoration: InputDecoration(
                labelText: l10n.titleLabel,
                border: const OutlineInputBorder(),
                errorText: isSubmitting
                    ? ProductFormValidator.validateTitle(
                        titleController.text,
                        context,
                      )
                    : null,
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              onChanged: onTitleChanged,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),

          // Description Field
          Directionality(
            textDirection: textDirection,
            child: TextFormField(
              controller: descriptionController,
              textDirection: textDirection,
              decoration: InputDecoration(
                labelText: l10n.description,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                errorText: isSubmitting
                    ? ProductFormValidator.validateDescription(
                        descriptionController.text,
                        context,
                      )
                    : null,
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: onDescriptionChanged,
              maxLines: 3,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),

          // Price Field
          Directionality(
            textDirection: textDirection,
            child: TextFormField(
              controller: priceController,
              textDirection: textDirection,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.priceLabel,
                border: const OutlineInputBorder(),
                prefixText: '\$ ',
                errorText: isSubmitting
                    ? ProductFormValidator.validatePrice(
                        priceController.text,
                        context,
                      )
                    : null,
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              onChanged: onPriceChanged,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.done,
            ),
          ),
        ],
      ),
    );
  }
}

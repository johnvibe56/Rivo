import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivo/core/error/error_boundary.dart';
import 'package:rivo/core/navigation/app_navigation.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/features/product_upload/domain/validators/product_form_validator.dart';
import 'package:rivo/features/product_upload/presentation/providers/product_upload_provider.dart';
import 'package:rivo/features/product_upload/presentation/widgets/upload_form_fields.dart';
import 'package:rivo/features/product_upload/presentation/widgets/upload_states.dart';
import 'package:rivo/l10n/app_localizations.dart';

enum UploadState { initial, loading, success, error }

class ProductUploadScreen extends ConsumerStatefulWidget {
  const ProductUploadScreen({super.key});

  @override
  ConsumerState<ProductUploadScreen> createState() => _ProductUploadScreenState();
}

class _ProductUploadScreenState extends ConsumerState<ProductUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _debounceTimer = <String, Timer>{};
  
  File? _imageFile;
  UploadState _uploadState = UploadState.initial;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    for (final timer in _debounceTimer.values) {
      timer.cancel();
    }
    _debounceTimer.clear();
    super.dispose();
  }

  void _onTitleChanged(String value) {
    _debounceField('title', value, () {
      if (_formKey.currentState?.validate() ?? false) {
        // Field is valid, update state if needed
      }
    });
  }

  void _onDescriptionChanged(String value) {
    _debounceField('description', value, () {
      if (_formKey.currentState?.validate() ?? false) {
        // Field is valid, update state if needed
      }
    });
  }

  void _onPriceChanged(String value) {
    _debounceField('price', value, () {
      if (_formKey.currentState?.validate() ?? false) {
        // Field is valid, update state if needed
      }
    });
  }

  void _debounceField(String field, String value, VoidCallback callback) {
    _debounceTimer[field]?.cancel();
    _debounceTimer[field] = Timer(const Duration(milliseconds: 500), callback);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      
      if (pickedFile != null && mounted) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('${AppLocalizations.of(context)!.failedToPickImage}: $e');
      }
    }
  }

  void _removeImage() {
    setState(() => _imageFile = null);
  }

  bool _validateForm() {
    if (_formKey.currentState?.validate() != true) {
      setState(() {}); // Trigger validation
      return false;
    }
    
    final imageError = ProductFormValidator.validateImage(_imageFile, context);
    if (imageError != null) {
      _showErrorSnackBar(imageError);
      return false;
    }
    
    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;
    
    setState(() {
      _uploadState = UploadState.loading;
      _errorMessage = null;
    });

    try {
      final productData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'image_file': _imageFile!,
      };

      final success = await ref
          .read(productUploadProvider.notifier)
          .uploadProduct(productData);

      if (!mounted) return;

      if (success) {
        setState(() => _uploadState = UploadState.success);
      } else {
        throw Exception(AppLocalizations.of(context)!.uploadFailed);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadState = UploadState.error;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _imageFile = null;
      _uploadState = UploadState.initial;
      _errorMessage = null;
    });
  }

  void _navigateToFeed() {
    if (mounted) {
      AppNavigation.goToFeed(context);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isSubmitting = _uploadState == UploadState.loading;

    return ErrorBoundary(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addNewProduct),
          actions: [
            if (isSubmitting)
              const Padding(
                padding: EdgeInsetsDirectional.only(end: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(theme, l10n, isSubmitting),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n, bool isSubmitting) {
    switch (_uploadState) {
      case UploadState.loading:
        return const UploadLoadingWidget();
      case UploadState.success:
        return UploadSuccessWidget(
          onContinueShopping: _navigateToFeed,
          onViewProduct: () {
            // TODO: Navigate to the uploaded product
            _navigateToFeed();
          },
        );
      case UploadState.error:
        return UploadErrorWidget(
          errorMessage: _errorMessage ?? l10n.somethingWentWrong,
          onRetry: _submitForm,
          onCancel: _resetForm,
        );
      case UploadState.initial:
        return _buildForm(theme, l10n, isSubmitting);
    }
  }

  Widget _buildForm(ThemeData theme, AppLocalizations l10n, bool isSubmitting) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UploadFormFields(
            titleController: _titleController,
            descriptionController: _descriptionController,
            priceController: _priceController,
            imageFile: _imageFile,
            isSubmitting: isSubmitting,
            onTitleChanged: _onTitleChanged,
            onDescriptionChanged: _onDescriptionChanged,
            onPriceChanged: _onPriceChanged,
            onImageSelected: _pickImage,
            onImageRemoved: _removeImage,
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            onPressed: isSubmitting ? null : _submitForm,
            label: l10n.uploadProduct,
            isLoading: isSubmitting,
            fullWidth: true,
          ),
        ],
      ),
    );
  }


}


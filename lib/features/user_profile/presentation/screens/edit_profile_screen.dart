import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivo/core/navigation/app_navigation.dart';
import 'package:rivo/core/utils/validation_utils.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:rivo/features/user_profile/presentation/widgets/profile_image_picker.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  File? _pickedImage;
  bool _isUsernameAvailable = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  Timer? _debounce;
  Timer? _saveDebounce;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _debounce?.cancel();
    _saveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    
    try {
      final user = ref.read(authStateProvider).value?.user;
      if (user == null) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      await _loadUserProfile(user.id);
    } catch (e) {
      if (mounted) {
        final errorMessage = AppLocalizations.of(context)!.errorLoadingProfile;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    if (!mounted) return;

    try {
      final profile = await ref.read(userProfileProvider(userId).future);

      if (!mounted) return;

      setState(() {
        _usernameController.text = profile.username;
        _bioController.text = profile.bio ?? '';
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoadingProfile),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _pickedImage = File(pickedFile.path);
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToPickImage),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkUsernameAvailability(value);
    });
    _markFormAsChanged();
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty || _usernameController.text == username) {
      if (mounted) {
        setState(() => _isUsernameAvailable = true);
      }
      return;
    }

    try {
      final isAvailable = await ref.read(userProfileRepositoryProvider).isUsernameAvailable(username);

      if (mounted) {
        setState(() => _isUsernameAvailable = isAvailable);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUsernameAvailable = false);
      }
    }
  }

  void _onBioChanged(String value) {
    _markFormAsChanged();
  }

  void _markFormAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges) return true;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.unsavedChanges),
        content: Text(AppLocalizations.of(context)!.discardChangesConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    // Cancel any pending save
    _saveDebounce?.cancel();

    setState(() => _isSaving = true);

    try {
      final authState = ref.read(authStateProvider).valueOrNull;
      final user = authState?.user;
      
      if (user == null) {
        if (context.mounted) {
          AppNavigation.goToLogin(context);
        }
        return;
      }
      
      await ref.read(userProfileRepositoryProvider).updateProfile(
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        imageFile: _pickedImage,
      );
      
      // Refresh the profile after update
      await _loadUserProfile(user.id);

      if (!mounted) return;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _hasUnsavedChanges = false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is Failure ? e.message : AppLocalizations.of(context)!.failedToUpdateProfile),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.username,
        hintText: AppLocalizations.of(context)!.enterYourUsername,
        errorText: _isUsernameAvailable 
            ? null 
            : AppLocalizations.of(context)!.usernameAlreadyTaken,
      ),
      onChanged: _onUsernameChanged,
      validator: (value) => ValidationUtils.validateUsernameAvailability(
        context, 
        value, 
        _isUsernameAvailable,
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.bio,
        hintText: AppLocalizations.of(context)!.tellUsAboutYourself,
      ),
      onChanged: _onBioChanged,
      validator: (value) => ValidationUtils.validateBio(context, value),
      maxLines: 3,
      maxLength: 200,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        
        final shouldPop = await _confirmDiscardChanges();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProfile),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _confirmDiscardChanges();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: ProfileImagePicker(
                    currentImagePath: ref.watch(authStateProvider).value?.user?.userMetadata?['avatar_url'],
                    pickedImage: _pickedImage,
                    onPickImage: _pickImage,
                    isLoading: _isSaving,
                  ),
                ),
                const SizedBox(height: 24),
                _buildUsernameField(),
                const SizedBox(height: 16),
                _buildBioField(),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 24.0),
                  child: AppButton.primary(
                    onPressed: (_isSaving || !_isUsernameAvailable) 
                        ? null 
                        : _saveProfile,
                    label: l10n.saveChanges,
                    isLoading: _isSaving,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

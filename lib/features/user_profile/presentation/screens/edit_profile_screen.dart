import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivo/core/constants/app_colors.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:rivo/features/user_profile/presentation/widgets/profile_avatar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _pickedImage;
  bool _isLoading = false;
  bool _isUsernameAvailable = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      Logger.d('🔄 [EditProfile] Starting to load profile...');
      
      // Get the current user ID for logging
      final userId = ref.read(authProvider).asData?.value.user?.id;
      Logger.d('👤 [EditProfile] Current user ID: $userId');
      
      if (userId == null) {
        throw const ServerException('No authenticated user found');
      }
      
      Logger.d('📡 [EditProfile] Fetching profile from repository...');
      final profile = await ref.read(userProfileRepositoryProvider).getCurrentUserProfile();
      
      Logger.d('✅ [EditProfile] Profile loaded successfully');
      Logger.d('   - ID: ${profile.id}');
      Logger.d('   - Username: ${profile.username}');
      Logger.d('   - Bio: ${profile.bio ?? 'N/A'}');
      Logger.d('   - Avatar URL: ${profile.avatarUrl ?? 'N/A'}');
      
      if (!mounted) return;
      
      setState(() {
        _usernameController.text = profile.username;
        _bioController.text = profile.bio ?? '';
        _isLoading = false;
      });
      
    } on ServerException catch (e, stackTrace) {
      Logger.e('❌ [EditProfile] Server error loading profile', stackTrace);
      Logger.e('   - Error: ${e.message}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.message}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('❌ [EditProfile] Unexpected error loading profile', stackTrace);
      Logger.e('   - Error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred while loading your profile'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkUsernameAvailability(value);
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty || _usernameController.text == username) {
      setState(() => _isUsernameAvailable = true);
      return;
    }

    try {
      final isAvailable = await ref
          .read(userProfileRepositoryProvider)
          .isUsernameAvailable(username);
          
      if (mounted) {
        setState(() => _isUsernameAvailable = isAvailable);
      }
    } catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      if (mounted) {
        setState(() => _isUsernameAvailable = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isUsernameAvailable) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(userProfileRepositoryProvider).updateProfile(
            username: _usernameController.text.trim(),
            bio: _bioController.text.trim(),
            imageFile: _pickedImage,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    ProfileAvatar(
                      radius: 50,
                      imageUrl: _pickedImage?.path,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  errorText: !_isUsernameAvailable
                      ? 'Username is already taken'
                      : null,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                onChanged: _onUsernameChanged,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(value)) {
                    return 'Only letters, numbers, ., -, _ are allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.edit_note),
                ),
                maxLines: 4,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _saveProfile(),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Changes'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

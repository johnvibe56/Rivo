import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotrue/gotrue.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rivo/core/constants/app_colors.dart';
import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/providers/auth_provider.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/auth/domain/models/auth_state.dart' as app_auth;

import 'package:rivo/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:rivo/features/user_profile/presentation/widgets/profile_avatar.dart';



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
  bool _isLoading = false;
  bool _isUsernameAvailable = true;
  Timer? _debounce;
  bool _isInitialized = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
      final authState = ref.read(authStateProvider);
      if (authState is AsyncData) {
        _handleAuthState(authState.value);
      }
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
    super.dispose();
  }
  
  // Helper method to show error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      ),
    );
  }


  void _handleAuthState(dynamic authState) {
    if (!mounted) return;
    
    try {
      User? user;
      if (authState is app_auth.AuthState) {
        // Defensive: check for 'session' property if present
        final session = (authState as dynamic).session;
        user = session != null ? session.user as User? : null;
      } else if (authState is AuthState) {
        user = authState.session?.user;
      }
      
      if (user == null) {
        Logger.d('⚠️ [EditProfile] No authenticated user found. Redirecting to login...');
        if (mounted) {
          setState(() => _isLoading = false);
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
        return;
      }
      
      // If we have a user, load the profile data
      _loadUserProfile(user.id);
    } catch (e, stackTrace) {
      Logger.e('❌ [EditProfile] Error in _handleAuthState', stackTrace);
      if (mounted) {
        setState(() => _isLoading = false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error authenticating. Please try again.')),
          );
        }
      }
    }
  }
  
  Future<void> _loadUserProfile(String userId) async {
    if (!mounted) return;
    
    try {
      Logger.d('👤 [EditProfile] Loading profile for user: $userId');
      
      final profile = await ref.read(userProfileRepositoryProvider).getCurrentUserProfile();
      
      if (!mounted) return;
      
      Logger.d('✅ [EditProfile] Profile loaded successfully');
      Logger.d('   - ID: ${profile.id}');
      Logger.d('   - Username: ${profile.username}');
      Logger.d('   - Bio: ${profile.bio ?? 'N/A'}');
      Logger.d('   - Avatar URL: ${profile.avatarUrl ?? 'N/A'}');
      Logger.d('   - Username: ${profile.username}');
      Logger.d('   - Bio: ${profile.bio ?? 'N/A'}');
      Logger.d('   - Avatar URL: ${profile.avatarUrl ?? 'N/A'}');
      
      setState(() {
        _usernameController.text = profile.username;
        _bioController.text = profile.bio ?? '';
        _isLoading = false;
      });
      
    } catch (e, stackTrace) {
      Logger.e('❌ [EditProfile] Error loading profile', stackTrace);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile. Please try again.')),
        );
      }
    }
  }

  Future<void> _loadProfile({bool isRetry = false}) async {
    if (!mounted) return;
    
    Logger.d('🔄 [EditProfile] ${isRetry ? 'Retrying' : 'Starting'} profile loading process... (Retry: $_retryCount/$_maxRetries)');
    
    if (!isRetry) {
      setState(() {
        _isLoading = true;
        _retryCount = 0; // Reset retry counter on new load
      });
    }
    
    try {
      // Small delay to ensure the widget is fully built
      await Future<void>.delayed(Duration.zero);
      
      if (!mounted) return;
      
      Logger.d('🔍 [EditProfile] Reading auth state...');
      final authState = ref.read(authStateProvider);
      
      // Handle loading state
      if (authState.isLoading) {
        Logger.d('⏳ [EditProfile] Auth state is still loading...');
        
        // Only retry if we haven't exceeded max retries
        if (_retryCount < _maxRetries) {
          _retryCount++;
          Logger.d('🔄 [EditProfile] Will retry in ${_retryDelay.inMilliseconds}ms (Attempt $_retryCount/$_maxRetries)');
          
          await Future<void>.delayed(_retryDelay);
          if (mounted) {
            return _loadProfile(isRetry: true);
          }
        } else {
          Logger.e('⚠️ [EditProfile] Max retries ($_maxRetries) reached while waiting for auth state', StackTrace.current);
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Timeout loading profile. Please try again.')),
            );
          }
        }
        return;
      }
      
      // Handle error state
      if (authState.hasError) {
        Logger.e('❌ [EditProfile] Error in auth state: ${authState.error}', StackTrace.current);
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error loading authentication state')),
          );
        }
        return;
      }
      
      // Handle the auth state
      final user = authState.value?.session?.user;
      if (user != null) {
        Logger.d('👤 [EditProfile] Current user ID: ${user.id}');
        Logger.d('📡 [EditProfile] Fetching profile from repository...');
        _loadUserProfile(user.id);
      }
      
      try {
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
        });
        
      } on ServerException catch (e) {
        // Check if this is a "profile not found" error
        if (e.toString().contains('Profile not found') || 
            e.toString().contains('no rows returned') ||
            e.toString().contains('profile was not created')) {
          Logger.d('ℹ️ [EditProfile] No profile found, creating a new one...');
          
          try {
            // Generate a default username from email or user ID
            final userEmail = user?.email;
            final userId = user?.id;
            final defaultUsername = (userEmail != null && userEmail.isNotEmpty && userId != null)
                ? userEmail.split('@').first
                : userId != null
                  ? 'user_${userId.substring(0, userId.length > 8 ? 8 : userId.length)}'
                  : 'user_default';
                
            Logger.d('🆕 [EditProfile] Creating profile with username: $defaultUsername');
            
            // Create a new profile with default values
            final newProfile = await ref.read(userProfileRepositoryProvider).createProfile(
              userId: userId ?? '',
              username: defaultUsername,
              bio: 'Hello! I\'m new here.',
              avatarUrl: user?.userMetadata != null ? user!.userMetadata!['avatar_url'] as String? : null,
            );
            
            Logger.d('✅ [EditProfile] Created new profile for user: ${userId ?? 'unknown'}');
            
            if (mounted) {
              setState(() {
                _usernameController.text = newProfile.username;
                _bioController.text = newProfile.bio ?? '';
              });
            }
            
            return; // Exit after creating profile
          } catch (createError, createStackTrace) {
            Logger.e('❌ [EditProfile] Error creating profile: $createError', createStackTrace);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to create profile. Please try again.'),
                  duration: Duration(seconds: 5),
                ),
              );
            }
            rethrow;
          }
        }
        
        // If it's not a "not found" error, rethrow to be handled by the outer catch
        rethrow;
      }
      
    } on ServerException catch (e, stackTrace) {
      Logger.e('❌ [EditProfile] Server error loading profile: ${e.message}', stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.message}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('❌ [EditProfile] Unexpected error loading profile: $e', stackTrace);
      
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
      // Invalidate profile provider immediately after update
      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      String errorMsg = 'Failed to update profile';
      if (e is Exception) {
        errorMsg = e.toString();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
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

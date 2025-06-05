import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/error/failures.dart' show NoInternetFailure, UnauthenticatedFailure;
import 'package:rivo/features/follow/presentation/providers/follow_provider.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

class FollowButton extends ConsumerStatefulWidget {
  final String sellerId;
  final double? size;
  final double? iconSize;
  final bool showText;
  final EdgeInsetsGeometry? padding;

  const FollowButton({
    super.key,
    required this.sellerId,
    this.size = 40,
    this.iconSize = 20,
    this.showText = true,
    this.padding,
  });

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final followStatus = ref.watch(followStatusProvider(widget.sellerId));
    
    return followStatus.when(
      data: (result) => result.when(
        success: (isFollowing) => _buildButton(context, ref, isFollowing),
        failure: (_) => _buildButton(context, ref, false),
      ),
      loading: () => _buildLoadingButton(context, false),
      error: (_, __) => _buildButton(context, ref, false),
    );
  }



  Widget _buildButton(
      BuildContext context, WidgetRef ref, bool isFollowing) {
    if (_isLoading) {
      return _buildLoadingButton(context, isFollowing);
    }
    
    final buttonVariant = isFollowing ? AppButtonVariant.secondary : AppButtonVariant.primary;
    final label = isFollowing 
        ? AppLocalizations.of(context)!.following 
        : AppLocalizations.of(context)!.follow;
    final icon = isFollowing ? Icons.person_remove : Icons.person_add;
    
    switch (buttonVariant) {
      case AppButtonVariant.primary:
        return AppButton.primary(
          onPressed: () => _toggleFollow(context, ref, isFollowing),
          label: label,
          icon: icon,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 36,
          borderRadius: 20,
        );
      case AppButtonVariant.secondary:
        return AppButton.secondary(
          onPressed: () => _toggleFollow(context, ref, isFollowing),
          label: label,
          icon: icon,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 36,
          borderRadius: 20,
        );
      default:
        return AppButton.primary(
          onPressed: () => _toggleFollow(context, ref, isFollowing),
          label: label,
          icon: icon,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 36,
          borderRadius: 20,
        );
    }
  }

  Widget _buildLoadingButton(BuildContext context, bool isFollowing) {
    final buttonVariant = isFollowing ? AppButtonVariant.secondary : AppButtonVariant.primary;
    final label = isFollowing 
        ? AppLocalizations.of(context)!.following 
        : AppLocalizations.of(context)!.follow;
    final icon = isFollowing ? Icons.person_remove : Icons.person_add;
    
    switch (buttonVariant) {
      case AppButtonVariant.primary:
        return AppButton.primary(
          onPressed: null,
          label: label,
          icon: icon,
          isLoading: true,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 36,
          borderRadius: 20,
        );
      case AppButtonVariant.secondary:
        return AppButton.secondary(
          onPressed: null,
          label: label,
          icon: icon,
          isLoading: true,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 36,
          borderRadius: 20,
        );
      default:
        return AppButton.primary(
          onPressed: null,
          label: label,
          icon: icon,
          isLoading: true,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 36,
          borderRadius: 20,
        );
    }
  }

  Future<void> _toggleFollow(
    BuildContext context,
    WidgetRef ref, 
    bool isCurrentlyFollowing,
  ) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final repository = ref.read(followRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    
    try {
      // Perform the follow/unfollow action
      final result = isCurrentlyFollowing
          ? await repository.unfollowSeller(widget.sellerId)
          : await repository.followSeller(widget.sellerId);
      
      // Handle the result
      result.when(
        success: (_) {
          // Show success message
          if (context.mounted) {
            final message = isCurrentlyFollowing 
                ? l10n.unfollowedSeller 
                : l10n.followedSeller;
                
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      isCurrentlyFollowing ? Icons.person_remove : Icons.person_add,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            );
            
            // Refresh the UI
            ref.invalidate(followStatusProvider(widget.sellerId));
            ref.invalidate(followsProvider);
            ref.invalidate(followedSellerIdsProvider);
          }
        },
        failure: (failure) {
          try {
            // Safely access the error
            final error = failure.error;
            
            // Only show critical errors to the user
            if (error is NoInternetFailure || error is UnauthenticatedFailure) {
              if (context.mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      error is NoInternetFailure 
                          ? l10n.noInternetConnection
                          : l10n.pleaseSignInToContinue,
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              // Log other errors
              debugPrint('Follow/Unfollow error: ${error.toString()}');
              if (failure.stackTrace != null) {
                debugPrint('Stack trace: ${failure.stackTrace}');
              }
            }
          } catch (e, stackTrace) {
            // Catch any errors that might occur during error handling
            debugPrint('Error handling follow/unfollow failure: $e');
            debugPrint('Error stack trace: $stackTrace');
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in follow/unfollow: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      // Final refresh to ensure consistency
      if (context.mounted) {
        ref.invalidate(followStatusProvider(widget.sellerId));
        ref.invalidate(followsProvider);
      }
    }
  }
}

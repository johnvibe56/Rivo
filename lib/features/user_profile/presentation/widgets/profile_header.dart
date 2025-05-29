import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/error/result.dart';
import 'package:rivo/core/router/app_router.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/follow/presentation/providers/follow_provider.dart';
import 'package:rivo/features/follow/presentation/widgets/follow_button.dart';

class ProfileHeader extends ConsumerWidget {
  final String userId;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final int? productCount;
  final bool isCurrentUser;
  final bool showBackButton;

  const ProfileHeader({
    super.key,
    required this.userId,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.productCount = 0,
    this.isCurrentUser = false,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authStateProvider).valueOrNull?.user;
    final showFollowButton = !isCurrentUser && currentUser?.id != userId;
    
    // Watch follower and following counts
    final followerCountAsync = ref.watch(followerCountProvider(userId));
    final followingCountAsync = ref.watch(followingCountProvider(userId));
    
    // Handle back navigation
    void handleBack() {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      } else {
        context.go(AppRouter.getFullPath(AppRoutes.feed));
      }
    }

    final userName = displayName ?? 'User ${userId.substring(0, 8)}';
    
    // Helper function to build count text
    String getCountText(AsyncValue<Result<int>> asyncValue) {
      return asyncValue.when(
        data: (result) => result.when(
          success: (count) => count.toString(),
          failure: (_) => '0',
        ),
        loading: () => '...',
        error: (_, __) => '0',
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBackButton) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: handleBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
              ],
              // User Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          '$avatarUrl?cb=${DateTime.now().millisecondsSinceEpoch}',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar(theme);
                          },
                        ),
                      )
                    : _buildDefaultAvatar(theme),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (bio != null && bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        bio!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatColumn('Posts', productCount?.toString() ?? '0'),
                        _buildStatColumn('Followers', getCountText(followerCountAsync)),
                        _buildStatColumn('Following', getCountText(followingCountAsync)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showFollowButton) ...[
            const SizedBox(height: 16),
            FollowButton(
              sellerId: userId,
              size: 32,
              iconSize: 16,
              showText: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Icon(
      Icons.person,
      size: 40,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
// A simplified version of the profile header for use in lists
class CompactProfileHeader extends ConsumerWidget {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final bool showFollowButton;

  const CompactProfileHeader({
    super.key,
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.showFollowButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authStateProvider).valueOrNull?.user;
    final shouldShowFollowButton = showFollowButton && currentUser?.id != userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // User Avatar
           Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               CircleAvatar(
                 radius: 20,
                 backgroundColor: theme.colorScheme.surfaceContainerHighest,
                 child: avatarUrl != null
                     ? ClipOval(
                         child: Image.network(
                           '$avatarUrl?cb=${DateTime.now().millisecondsSinceEpoch}',
                           width: 40,
                           height: 40,
                           fit: BoxFit.cover,
                           errorBuilder: (context, error, stackTrace) {
                             return Icon(
                               Icons.person,
                               size: 20,
                               color: theme.colorScheme.onSurfaceVariant,
                             );
                           },
                         ),
                       )
                     : Icon(
                         Icons.person,
                         size: 20,
                         color: theme.colorScheme.onSurfaceVariant,
                       ),
               ),

             ],
           ),
          const SizedBox(width: 12),
          
          // Display Name
          Expanded(
            child: Text(
              displayName ?? 'User ${userId.substring(0, 6)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Follow Button
          if (shouldShowFollowButton) ...[
            const SizedBox(width: 8),
            FollowButton(
              sellerId: userId,
              size: 28,
              iconSize: 16,
              showText: false,
              padding: const EdgeInsets.all(6),
            ),
          ],
        ],
      ),
    );
  }
}

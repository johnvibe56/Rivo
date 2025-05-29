import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/constants/app_colors.dart';
import 'package:rivo/core/router/app_router.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/follow/presentation/widgets/follow_button.dart';

class ProfileHeader extends ConsumerWidget {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final int? followerCount;
  final int? followingCount;
  final int? productCount;
  final bool isCurrentUser;

  const ProfileHeader({
    super.key,
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.followerCount,
    this.followingCount,
    this.productCount,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authStateProvider).valueOrNull?.user;
    final showFollowButton = !isCurrentUser && currentUser?.id != userId;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar
               Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   CircleAvatar(
                     radius: 40,
                     backgroundColor: theme.colorScheme.surfaceContainerHighest,
                     child: avatarUrl != null
                         ? ClipOval(
                             child: Image.network(
                               avatarUrl! + '?cb=${DateTime.now().millisecondsSinceEpoch}',
                               width: 80,
                               height: 80,
                               fit: BoxFit.cover,
                               errorBuilder: (context, error, stackTrace) {
                                 return Icon(
                                   Icons.person,
                                   size: 40,
                                   color: theme.colorScheme.onSurfaceVariant,
                                 );
                               },
                             ),
                           )
                         : Icon(
                             Icons.person,
                             size: 40,
                             color: theme.colorScheme.onSurfaceVariant,
                           ),
                   ),

                 ],
               ),
              const SizedBox(width: 24),
              
              // User Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Name and Follow Button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName ?? 'User ${userId.substring(0, 6)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              context.push(AppRouter.getFullPath(AppRoutes.editProfile));
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              side: BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Edit Profile',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (showFollowButton) ...[
                          const SizedBox(width: 8),
                          FollowButton(
                            sellerId: userId,
                            size: 32,
                            iconSize: 18,
                            showText: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          context,
                          count: productCount ?? 0,
                          label: 'Products',
                        ),
                        _buildStatColumn(
                          context,
                          count: followerCount ?? 0,
                          label: 'Followers',
                        ),
                        _buildStatColumn(
                          context,
                          count: followingCount ?? 0,
                          label: 'Following',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStatColumn(
    BuildContext context, {
    required int count,
    required String label,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
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
                           avatarUrl! + '?cb=${DateTime.now().millisecondsSinceEpoch}',
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

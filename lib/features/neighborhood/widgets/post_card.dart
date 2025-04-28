import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../domain/models/post.dart';
import '../presentation/providers/neighborhood_provider.dart';
import 'badge_label.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final bool isInDetailView;
  
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.isInDetailView = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Hero(
      tag: 'post-${post.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 12),
                _buildContent(theme),
                if (post.images != null && post.images!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: post.images!.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 14),
                _buildInteractionBar(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        // Author avatar
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            post.authorName.substring(0, 1),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  post.authorName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(width: 4),
                BadgeLabel(
                  text: post.category,
                  fontSize: 11,
                ),
              ],
            ),
            Text(
              post.location,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          _formatTimeAgo(post.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onBackground.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
  
  Widget _buildContent(ThemeData theme) {
    return Text(
      post.content,
      style: TextStyle(
        fontSize: 15,
        height: 1.4,
        color: theme.colorScheme.onBackground.withOpacity(0.9),
      ),
      maxLines: isInDetailView ? null : 4,
      overflow: isInDetailView ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }
  
  Widget _buildInteractionBar(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        _buildInteractionButton(
          context: context,
          icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
          iconColor: post.isLiked ? Colors.red : theme.colorScheme.onBackground.withOpacity(0.5),
          label: post.likesCount.toString(),
          theme: theme,
          onTap: () {
            Provider.of<NeighborhoodProvider>(context, listen: false).likePost(post.id);
          },
        ),
        const SizedBox(width: 16),
        _buildInteractionButton(
          context: context,
          icon: Icons.chat_bubble_outline,
          iconColor: theme.colorScheme.onBackground.withOpacity(0.5),
          label: post.commentsCount.toString(),
          theme: theme,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            // Share post
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('공유 기능은 준비 중입니다'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 100,
                  left: 16,
                  right: 16,
                ),
              ),
            );
          },
          child: Icon(
            Icons.share_outlined,
            size: 18,
            color: theme.colorScheme.onBackground.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInteractionButton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
} 
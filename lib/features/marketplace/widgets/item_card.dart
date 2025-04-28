import 'package:flutter/material.dart';
import '../models/market_item.dart';
import '../utils/formatters.dart';

class MarketItemCard extends StatelessWidget {
  final MarketItem item;
  final VoidCallback onTap;
  final Function(bool) onBookmarkToggle;
  final bool showTranslation;
  final VoidCallback? onTranslationToggle;
  final bool showDistance;
  
  const MarketItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onBookmarkToggle,
    this.showTranslation = false,
    this.onTranslationToggle,
    this.showDistance = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with improved loading and hero animation
              Hero(
                tag: 'item-image-${item.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: item.images.isNotEmpty
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                item.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: theme.colorScheme.surfaceVariant,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                    ),
                                  );
                                },
                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded) return child;
                                  return AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    child: child,
                                  );
                                },
                              ),
                              if (item.isNegotiable)
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.tertiaryContainer.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '가격제안가능',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (showDistance && item.distanceInKm != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.near_me,
                              size: 14,
                              color: theme.colorScheme.primary.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.distanceInKm!.toStringAsFixed(1)}km',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.formatPrice(item.price.toInt()),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatItem(theme, Icons.favorite_border, item.likes.toString()),
                        const SizedBox(width: 12),
                        _buildStatItem(theme, Icons.chat_bubble_outline, item.chats.toString()),
                        if (item.timeAgo.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          _buildStatItem(theme, Icons.access_time_rounded, item.timeAgo),
                        ],
                        const Spacer(),
                        // Animated bookmark button
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: GestureDetector(
                            key: ValueKey(item.isBookmarked),
                            onTap: () => onBookmarkToggle(!item.isBookmarked),
                            child: Icon(
                              item.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              size: 20,
                              color: item.isBookmarked
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        const SizedBox(width: 3),
        Text(
          count,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 
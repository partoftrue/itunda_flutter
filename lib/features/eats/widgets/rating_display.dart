import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double? fontSize;
  final Color? color;
  final bool showReviewCount;
  final bool compact;

  const RatingDisplay({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.fontSize,
    this.color,
    this.showReviewCount = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;
    final starColor = theme.colorScheme.primary;
    final effectiveFontSize = fontSize ?? 14.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: effectiveFontSize * 1.2,
          color: starColor,
        ),
        const SizedBox(width: 2),
        Text(
          EatsFormatters.formatRating(rating),
          style: TextStyle(
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.w600,
            color: effectiveColor,
            height: 1.2,
          ),
        ),
        if (showReviewCount) ...[
          if (compact)
            Text(
              ' (${EatsFormatters.formatReviewCount(reviewCount)})',
              style: TextStyle(
                fontSize: effectiveFontSize * 0.9,
                color: effectiveColor.withOpacity(0.7),
                height: 1.2,
              ),
            )
          else ...[
            const SizedBox(width: 8),
            Container(
              width: 2,
              height: 2,
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${EatsFormatters.formatReviewCount(reviewCount)} reviews',
              style: TextStyle(
                fontSize: effectiveFontSize * 0.9,
                color: effectiveColor.withOpacity(0.7),
                height: 1.2,
              ),
            ),
          ],
        ],
      ],
    );
  }
} 
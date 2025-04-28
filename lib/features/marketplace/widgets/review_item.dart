import 'package:flutter/material.dart';
import '../models/review.dart';
import 'package:intl/intl.dart';

class ReviewItem extends StatelessWidget {
  final Review review;

  const ReviewItem({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 16,
                backgroundImage: review.userAvatar != null 
                    ? NetworkImage(review.userAvatar!) 
                    : null,
                child: review.userAvatar == null
                    ? Icon(Icons.person, size: 16, color: theme.colorScheme.onPrimary)
                    : null,
              ),
              SizedBox(width: 8),
              
              // User name
              Text(
                review.userName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              
              // Rating
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 4),
                  Text(
                    review.rating.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Review content
          if (review.comment != null && review.comment!.isNotEmpty) 
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 0),
              child: Text(
                review.comment!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          
          // Date
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _formatDate(review.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date);
  }
} 
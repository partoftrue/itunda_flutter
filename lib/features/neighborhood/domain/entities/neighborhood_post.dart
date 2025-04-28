import 'package:equatable/equatable.dart';
import 'package:finance_app/features/neighborhood/domain/entities/neighborhood_comment.dart';

class NeighborhoodPost extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;
  final List<NeighborhoodComment>? comments;

  const NeighborhoodPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.isLiked,
    this.comments,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        content,
        imageUrl,
        createdAt,
        likeCount,
        isLiked,
        comments,
      ];
} 
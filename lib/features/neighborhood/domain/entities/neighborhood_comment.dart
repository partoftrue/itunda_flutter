import 'package:equatable/equatable.dart';

class NeighborhoodComment extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;

  const NeighborhoodComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.isLiked,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        content,
        createdAt,
        likeCount,
        isLiked,
      ];
} 
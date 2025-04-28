import 'package:finance_app/features/neighborhood/domain/entities/neighborhood_comment.dart';

/// Data Transfer Object for Neighborhood Comments
class CommentDTO {
  final String? id;
  final String? postId;
  final String? authorId;
  final String? authorName;
  final String? authorProfileImage;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;

  CommentDTO({
    this.id,
    this.postId,
    this.authorId,
    this.authorName,
    this.authorProfileImage,
    required this.content,
    DateTime? createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Factory constructor for creating a CommentDTO from JSON
  factory CommentDTO.fromJson(Map<String, dynamic> json) {
    return CommentDTO(
      id: json['id'],
      postId: json['postId'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorProfileImage: json['authorProfileImage'],
      content: json['content'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  /// Convert CommentDTO to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'content': content,
    };

    if (id != null) data['id'] = id;
    if (postId != null) data['postId'] = postId;
    if (authorId != null) data['authorId'] = authorId;

    return data;
  }

  /// Convert CommentDTO to domain model NeighborhoodComment
  NeighborhoodComment toDomain() {
    return NeighborhoodComment(
      id: id ?? '',
      postId: postId ?? '',
      authorId: authorId ?? '',
      authorName: authorName ?? 'Anonymous',
      authorProfileImage: authorProfileImage,
      content: content,
      createdAt: createdAt,
      likeCount: likeCount,
      isLiked: isLiked,
    );
  }

  /// Create a CommentDTO from a domain model
  factory CommentDTO.fromDomain(NeighborhoodComment comment, String postId, String authorId) {
    return CommentDTO(
      id: comment.id.isEmpty ? null : comment.id,
      postId: postId,
      authorId: authorId,
      content: comment.content,
      createdAt: comment.createdAt,
      likeCount: comment.likeCount,
      isLiked: comment.isLiked,
    );
  }
} 
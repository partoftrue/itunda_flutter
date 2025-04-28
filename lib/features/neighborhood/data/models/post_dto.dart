import 'package:finance_app/features/neighborhood/domain/entities/neighborhood_post.dart';

/// Data Transfer Object for Neighborhood Posts
class PostDTO {
  final String? id;
  final String? authorId;
  final String? authorName;
  final String? authorProfileImage;
  final String title;
  final String content;
  final String category;
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final List<String>? imageUrls;

  PostDTO({
    this.id,
    this.authorId,
    this.authorName,
    this.authorProfileImage,
    required this.title,
    required this.content,
    required this.category,
    required this.location,
    DateTime? createdAt,
    this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.imageUrls,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Factory constructor for creating a PostDTO from JSON
  factory PostDTO.fromJson(Map<String, dynamic> json) {
    return PostDTO(
      id: json['id'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorProfileImage: json['authorProfileImage'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      location: json['location'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
    );
  }

  /// Convert PostDTO to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'content': content,
      'category': category,
      'location': location,
    };

    if (id != null) data['id'] = id;
    if (authorId != null) data['authorId'] = authorId;
    if (imageUrls != null) data['imageUrls'] = imageUrls;

    return data;
  }

  /// Convert PostDTO to domain model NeighborhoodPost
  NeighborhoodPost toDomain() {
    return NeighborhoodPost(
      id: id ?? '',
      authorId: authorId ?? '',
      authorName: authorName ?? 'Anonymous',
      authorProfileImage: authorProfileImage,
      title: title,
      content: content,
      category: category,
      location: location,
      createdAt: createdAt,
      updatedAt: updatedAt,
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLiked,
      imageUrls: imageUrls ?? [],
    );
  }

  /// Create a PostDTO from a domain model
  factory PostDTO.fromDomain(NeighborhoodPost post, String postId, String authorId) {
    return PostDTO(
      id: postId.isEmpty ? null : postId,
      authorId: authorId,
      title: post.title,
      content: post.content,
      category: post.category,
      location: post.location,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      isLiked: post.isLiked,
      imageUrls: post.imageUrls.isNotEmpty ? post.imageUrls : null,
    );
  }
} 
import 'package:equatable/equatable.dart';
import 'comment.dart';

class Post extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final String category;
  final bool isLiked;
  final List<Comment>? comments;
  final List<String>? images;
  final String location;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.category,
    required this.isLiked,
    this.comments,
    this.images,
    this.location = '서울특별시 강남구',
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        authorId,
        authorName,
        authorAvatar,
        createdAt,
        updatedAt,
        likesCount,
        commentsCount,
        category,
        isLiked,
        comments,
        images,
        location,
      ];

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    String? category,
    bool? isLiked,
    List<Comment>? comments,
    List<String>? images,
    String? location,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      category: category ?? this.category,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
      images: images ?? this.images,
      location: location ?? this.location,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      likesCount: json['likesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      category: json['category'] as String,
      isLiked: json['isLiked'] as bool,
      comments: json['comments'] != null ? List<Comment>.from(json['comments'].map((x) => Comment.fromJson(x))) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      location: json['location'] as String? ?? '서울특별시 강남구',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'category': category,
      'isLiked': isLiked,
      'comments': comments?.map((x) => x.toJson()).toList(),
      'images': images,
      'location': location,
    };
  }
} 
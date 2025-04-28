import 'package:json_annotation/json_annotation.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  final int? id;
  final String category;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String location;
  final int likes;
  final int comments;
  final List<String> images;
  
  @JsonKey(name: 'createdAt')
  final DateTime postDate;
  
  final DateTime updatedAt;

  PostModel({
    this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.location,
    this.likes = 0,
    this.comments = 0,
    this.images = const [],
    required this.postDate,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);
  Map<String, dynamic> toJson() => _$PostModelToJson(this);
  
  // Convert to a DTO for creating/updating
  Map<String, dynamic> toCreateDto() {
    return {
      'category': category,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'location': location,
      'images': images,
    };
  }
  
  Map<String, dynamic> toUpdateDto() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'images': images,
    };
  }
  
  PostModel copyWith({
    int? id,
    String? category,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? location,
    int? likes,
    int? comments,
    List<String>? images,
    DateTime? postDate,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      location: location ?? this.location,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      images: images ?? this.images,
      postDate: postDate ?? this.postDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
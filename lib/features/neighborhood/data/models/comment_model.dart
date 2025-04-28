import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final int? id;
  final int postId;
  final String authorId;
  final String authorName;
  final String content;
  final int likes;
  
  @JsonKey(name: 'createdAt')
  final DateTime postDate;
  
  final DateTime updatedAt;

  CommentModel({
    this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.likes = 0,
    required this.postDate,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => _$CommentModelFromJson(json);
  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
  
  // Convert to a DTO for creating
  Map<String, dynamic> toCreateDto() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
    };
  }
  
  // Convert to a DTO for updating
  Map<String, dynamic> toUpdateDto() {
    return {
      'content': content,
    };
  }
  
  CommentModel copyWith({
    int? id,
    int? postId,
    String? authorId,
    String? authorName,
    String? content,
    int? likes,
    DateTime? postDate,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      postDate: postDate ?? this.postDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
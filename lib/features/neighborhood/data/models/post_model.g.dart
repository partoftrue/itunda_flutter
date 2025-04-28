// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
  id: (json['id'] as num?)?.toInt(),
  category: json['category'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  location: json['location'] as String,
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  comments: (json['comments'] as num?)?.toInt() ?? 0,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  postDate: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
  'id': instance.id,
  'category': instance.category,
  'title': instance.title,
  'content': instance.content,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'location': instance.location,
  'likes': instance.likes,
  'comments': instance.comments,
  'images': instance.images,
  'createdAt': instance.postDate.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

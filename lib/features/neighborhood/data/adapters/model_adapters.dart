import 'package:finance_app/features/neighborhood/data/models/comment_model.dart';
import 'package:finance_app/features/neighborhood/data/models/post_model.dart';

class NeighborhoodPostAdapter {
  // Convert from API model to UI model
  static Map<String, dynamic> toUiModel(PostModel model) {
    return {
      'id': model.id.toString(),
      'category': model.category,
      'title': model.title,
      'content': model.content,
      'authorName': model.authorName,
      'location': model.location,
      'likes': model.likes,
      'comments': model.comments,
      'postDate': model.postDate,
      'images': model.images,
    };
  }
  
  // Create API model from UI data
  static PostModel fromUiData({
    required String category,
    required String title,
    required String content,
    required String authorName,
    required String location,
    List<String> images = const [],
  }) {
    return PostModel(
      id: null,
      category: category,
      title: title,
      content: content,
      authorId: 'user123', // This would come from auth service
      authorName: authorName,
      location: location,
      images: images,
      postDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class CommentAdapter {
  // Convert from API model to UI model
  static Map<String, dynamic> toUiModel(CommentModel model) {
    return {
      'id': model.id.toString(),
      'postId': model.postId.toString(),
      'authorName': model.authorName,
      'content': model.content,
      'likes': model.likes,
      'postDate': model.postDate,
    };
  }
  
  // Create API model from UI data
  static CommentModel fromUiData({
    required int postId,
    required String content,
    required String authorName,
  }) {
    return CommentModel(
      id: null,
      postId: postId,
      authorId: 'user123', // This would come from auth service
      authorName: authorName,
      content: content,
      postDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
} 
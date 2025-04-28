import 'package:finance_app/features/neighborhood/data/models/comment_model.dart';
import 'package:finance_app/features/neighborhood/data/models/post_model.dart';

/// Interface for the neighborhood repository
abstract class NeighborhoodRepositoryInterface {
  /// Get all neighborhood posts
  Future<List<PostModel>> getPosts({String? category});
  
  /// Get posts filtered by category
  Future<List<PostModel>> getPopularPosts();
  
  /// Get a specific post by ID
  Future<PostModel?> getPostById(String postId);
  
  /// Create a new post
  Future<String> createPost(PostModel post);
  
  /// Update an existing post
  Future<void> updatePost(PostModel post);
  
  /// Delete a post
  Future<void> deletePost(String postId);
  
  /// Toggle like status for a post
  Future<void> toggleLike(String postId, bool isLiked);
  
  /// Get comments for a post
  Future<List<CommentModel>> getComments(String postId);
  
  /// Add a comment to a post
  Future<String> addComment(CommentModel comment);
  
  /// Delete a comment from a post
  Future<void> deleteComment(String postId, String commentId);
  
  /// Toggle like status for a comment
  Future<void> toggleCommentLike(String postId, String commentId, bool isLiked);
} 
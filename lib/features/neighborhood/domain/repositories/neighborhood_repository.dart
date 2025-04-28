import '../models/post.dart';
import '../models/comment.dart';
import '../models/category.dart';

/// Interface for the neighborhood repository
abstract class NeighborhoodRepository {
  /// Get all neighborhood posts
  Future<List<Post>> getPosts({String? category, int page, int size});
  
  /// Get popular posts
  Future<List<Post>> getPopularPosts({int page, int size});
  
  /// Get a specific post by ID
  Future<Post?> getPostById(String postId);
  
  /// Create a new post
  Future<String> createPost(Post post);
  
  /// Update an existing post
  Future<void> updatePost(Post post);
  
  /// Delete a post
  Future<void> deletePost(String postId);
  
  /// Toggle like status for a post
  Future<void> toggleLike(String postId, bool isLiked);
  
  /// Get comments for a post
  Future<List<Comment>> getComments(String postId);
  
  /// Add a comment to a post
  Future<String> addComment(Comment comment);
  
  /// Delete a comment from a post
  Future<void> deleteComment(String postId, String commentId);
  
  /// Toggle like status for a comment
  Future<void> toggleCommentLike(String postId, String commentId, bool isLiked);
  
  /// Get all available categories
  Future<List<Category>> getCategories();
} 
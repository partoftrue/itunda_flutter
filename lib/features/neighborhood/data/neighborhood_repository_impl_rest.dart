import 'package:flutter/foundation.dart';
import 'package:finance_app/features/neighborhood/data/api/neighborhood_api_client.dart';
import 'package:finance_app/features/neighborhood/data/models/comment_model.dart';
import 'package:finance_app/features/neighborhood/data/models/post_model.dart';
import 'package:finance_app/features/neighborhood/domain/neighborhood_repository_interface.dart';

class NeighborhoodRepositoryRest implements NeighborhoodRepositoryInterface {
  final NeighborhoodApiClient _apiClient;
  
  // Current user info - would be provided by auth service
  final String _userId = 'user123';
  final String _location = '역삼동';
  
  NeighborhoodRepositoryRest({NeighborhoodApiClient? apiClient})
      : _apiClient = apiClient ?? NeighborhoodApiClient();
  
  @override
  Future<List<PostModel>> getPosts({String? category}) async {
    try {
      final postsData = await _apiClient.getPosts(
        location: _location,
        category: category ?? '전체',
      );
      
      return postsData.map((data) => PostModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      rethrow;
    }
  }
  
  @override
  Future<PostModel?> getPostById(String postId) async {
    try {
      final postData = await _apiClient.getPostById(
        postId,
        _userId,
        _location,
      );
      
      return PostModel.fromJson(postData);
    } catch (e) {
      debugPrint('Error fetching post by ID: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<PostModel>> getPopularPosts() async {
    try {
      final postsData = await _apiClient.getPopularPosts(
        location: _location,
      );
      
      return postsData.map((data) => PostModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching popular posts: $e');
      rethrow;
    }
  }
  
  @override
  Future<String> createPost(PostModel post) async {
    try {
      final response = await _apiClient.createPost(post.toCreateDto());
      return response['id'].toString();
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updatePost(PostModel post) async {
    try {
      await _apiClient.updatePost(post.id.toString(), post.toUpdateDto());
    } catch (e) {
      debugPrint('Error updating post: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deletePost(String postId) async {
    try {
      await _apiClient.deletePost(postId);
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> toggleLike(String postId, bool isLiked) async {
    try {
      await _apiClient.likePost(postId, _userId);
    } catch (e) {
      debugPrint('Error toggling post like: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final commentsData = await _apiClient.getCommentsByPostId(postId);
      return commentsData.map((data) => CommentModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      rethrow;
    }
  }
  
  @override
  Future<String> addComment(CommentModel comment) async {
    try {
      final response = await _apiClient.createComment(comment.toCreateDto());
      return response['id'].toString();
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _apiClient.deleteComment(commentId);
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> toggleCommentLike(String postId, String commentId, bool isLiked) async {
    try {
      await _apiClient.likeComment(commentId);
    } catch (e) {
      debugPrint('Error toggling comment like: $e');
      rethrow;
    }
  }
  
  void dispose() {
    _apiClient.dispose();
  }
} 
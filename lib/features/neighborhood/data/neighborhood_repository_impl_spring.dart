import 'package:finance_app/features/neighborhood/data/api/spring_neighborhood_api_client.dart';
import 'package:finance_app/features/neighborhood/data/models/post_dto.dart';
import 'package:finance_app/features/neighborhood/data/models/comment_dto.dart';
import 'package:finance_app/features/neighborhood/domain/entities/neighborhood_post.dart';
import 'package:finance_app/features/neighborhood/domain/entities/neighborhood_comment.dart';
import 'package:finance_app/features/neighborhood/data/neighborhood_repository.dart';

/// Spring Boot implementation of the Neighborhood Repository
class NeighborhoodRepositorySpring implements NeighborhoodRepositoryInterface {
  final SpringNeighborhoodApiClient _apiClient;
  String _currentUserId = '';
  String _currentLocation = '서울';

  NeighborhoodRepositorySpring({SpringNeighborhoodApiClient? apiClient})
      : _apiClient = apiClient ?? SpringNeighborhoodApiClient();

  void updateCurrentUser(String userId) {
    _currentUserId = userId;
  }

  void updateLocation(String location) {
    _currentLocation = location;
  }

  @override
  Future<List<NeighborhoodPost>> getPosts(
      {required String category, int page = 0, int size = 20}) async {
    try {
      final response = await _apiClient.getPosts(
        location: _currentLocation,
        category: category,
        page: page,
        size: size,
      );

      final content = response['content'] as List<dynamic>;
      return content
          .map((json) => PostDTO.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      print('Failed to fetch posts: $e');
      return [];
    }
  }

  @override
  Future<NeighborhoodPost?> getPostById(String postId) async {
    try {
      final response = await _apiClient.getPostById(
        postId,
        _currentUserId,
        _currentLocation,
      );
      return PostDTO.fromJson(response).toDomain();
    } catch (e) {
      print('Failed to fetch post: $e');
      return null;
    }
  }

  @override
  Future<List<NeighborhoodPost>> getPopularPosts({int page = 0, int size = 10}) async {
    try {
      final response = await _apiClient.getPopularPosts(
        location: _currentLocation,
        page: page,
        size: size,
      );

      final content = response['content'] as List<dynamic>;
      return content
          .map((json) => PostDTO.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      print('Failed to fetch popular posts: $e');
      return [];
    }
  }

  @override
  Future<NeighborhoodPost?> createPost(NeighborhoodPost post) async {
    try {
      final postDTO = PostDTO.fromDomain(post, '', _currentUserId);
      final response = await _apiClient.createPost(postDTO.toJson());
      return PostDTO.fromJson(response).toDomain();
    } catch (e) {
      print('Failed to create post: $e');
      return null;
    }
  }

  @override
  Future<NeighborhoodPost?> updatePost(NeighborhoodPost post) async {
    try {
      final postDTO = PostDTO.fromDomain(post, post.id, _currentUserId);
      final response = await _apiClient.updatePost(post.id, postDTO.toJson());
      return PostDTO.fromJson(response).toDomain();
    } catch (e) {
      print('Failed to update post: $e');
      return null;
    }
  }

  @override
  Future<bool> deletePost(String postId) async {
    try {
      await _apiClient.deletePost(postId);
      return true;
    } catch (e) {
      print('Failed to delete post: $e');
      return false;
    }
  }

  @override
  Future<int> toggleLike(String postId) async {
    try {
      final response = await _apiClient.likePost(postId, _currentUserId);
      return response['likeCount'] as int;
    } catch (e) {
      print('Failed to toggle like: $e');
      return -1;
    }
  }

  @override
  Future<List<NeighborhoodComment>> getComments(String postId, {int page = 0, int size = 20}) async {
    try {
      final commentsList = await _apiClient.getCommentsByPostId(
        postId,
        page: page,
        size: size,
      );
      
      return commentsList
          .map((json) => CommentDTO.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      print('Failed to fetch comments: $e');
      return [];
    }
  }

  @override
  Future<NeighborhoodComment?> addComment(String postId, String content) async {
    try {
      final commentData = {
        'postId': postId,
        'authorId': _currentUserId,
        'content': content,
      };
      
      final response = await _apiClient.createComment(commentData);
      return CommentDTO.fromJson(response).toDomain();
    } catch (e) {
      print('Failed to add comment: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteComment(String commentId) async {
    try {
      await _apiClient.deleteComment(commentId);
      return true;
    } catch (e) {
      print('Failed to delete comment: $e');
      return false;
    }
  }

  @override
  Future<int> toggleCommentLike(String commentId) async {
    try {
      final response = await _apiClient.likeComment(commentId);
      return response['likeCount'] as int;
    } catch (e) {
      print('Failed to toggle comment like: $e');
      return -1;
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
} 
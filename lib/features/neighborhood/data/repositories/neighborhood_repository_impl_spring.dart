import 'package:http/http.dart' as http;
import 'package:finance_app/core/network/network_info.dart';
import 'package:finance_app/core/services/auth_service.dart';
import 'package:finance_app/features/neighborhood/data/api/spring_neighborhood_api_client.dart';
import 'package:finance_app/features/neighborhood/domain/models/post.dart';
import 'package:finance_app/features/neighborhood/domain/models/comment.dart';
import 'package:finance_app/features/neighborhood/domain/models/category.dart';
import 'package:finance_app/features/neighborhood/domain/repositories/neighborhood_repository.dart';
import 'package:finance_app/core/network/api_exception.dart';

class NeighborhoodRepositoryImplSpring implements NeighborhoodRepository {
  final SpringNeighborhoodApiClient _apiClient;
  final String _currentLocation;
  
  NeighborhoodRepositoryImplSpring({
    AuthService? authService,
    NetworkInfo? networkInfo,
    http.Client? httpClient,
    String currentLocation = '서울시',
  }) : 
    _currentLocation = currentLocation,
    _apiClient = SpringNeighborhoodApiClient(
      httpClient: httpClient,
      authService: authService ?? AuthService(
        baseUrl: 'https://api.finance-app.com',
      ),
    );
  
  @override
  Future<List<Post>> getPosts({
    String? category,
    int page = 0, 
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.getPosts(
        location: _currentLocation,
        category: category ?? '전체',
        page: page,
        size: size,
      );
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<List<Post>> getPopularPosts({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient.getPopularPosts(
        location: _currentLocation,
        page: page,
        size: size,
      );
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<Post?> getPostById(String postId) async {
    try {
      final response = await _apiClient.getPostById(postId);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<String> createPost(Post post) async {
    try {
      final response = await _apiClient.createPost(post);
      return response.id;
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<void> updatePost(Post post) async {
    try {
      await _apiClient.updatePost(post.id, post);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<void> deletePost(String postId) async {
    try {
      await _apiClient.deletePost(postId);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<void> toggleLike(String postId, bool isLiked) async {
    try {
      if (isLiked) {
        await _apiClient.likePost(postId);
      }
      // If unliking, we'd need an unlike endpoint that isn't provided
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<List<Comment>> getComments(String postId) async {
    try {
      final response = await _apiClient.getCommentsByPostId(postId);
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<String> addComment(Comment comment) async {
    try {
      final response = await _apiClient.createComment(comment);
      return response.id;
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _apiClient.deleteComment(commentId);
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  @override
  Future<void> toggleCommentLike(String postId, String commentId, bool isLiked) async {
    try {
      if (isLiked) {
        await _apiClient.likeComment(commentId);
      }
      // If unliking, we'd need an unlike endpoint that isn't provided
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  /// Get all available categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.getCategories();
      return response;
    } catch (e) {
      throw _handleException(e);
    }
  }
  
  Exception _handleException(dynamic e) {
    if (e is ApiException) {
      return e;
    }
    if (e is SpringApiException) {
      return ApiException(
        message: e.message,
        statusCode: e.statusCode,
      );
    }
    return NeighborhoodException(
      message: 'An unexpected error occurred: ${e.toString()}',
      code: NeighborhoodExceptionCode.unknown,
    );
  }
  
  /// Dispose resources used by this repository
  void dispose() {
    _apiClient.dispose();
  }
} 
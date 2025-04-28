import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:finance_app/features/neighborhood/data/api/api_config.dart';
import '../models/post_dto.dart';
import '../models/comment_dto.dart';
import 'neighborhood_api_interceptor.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/network_info.dart';

/// API client for handling neighborhood-related network requests
class NeighborhoodApiClient {
  final http.Client _httpClient;
  final NeighborhoodApiInterceptor _interceptor;
  final NetworkInfo _networkInfo;
  final String _baseUrl;
  
  NeighborhoodApiClient({
    required http.Client httpClient,
    required NeighborhoodApiInterceptor interceptor,
    required NetworkInfo networkInfo,
    required String baseUrl,
  })  : _httpClient = httpClient,
        _interceptor = interceptor,
        _networkInfo = networkInfo,
        _baseUrl = baseUrl;
  
  /// Get all neighborhood posts
  Future<List<PostDTO>> getPosts() async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts');
    
    try {
      final response = await _performRequest(
        () => _httpClient.get(
          uri,
          headers: await _interceptor.getHeaders(),
        ),
      );
      
      final jsonBody = json.decode(response.body);
      final List<dynamic> postsJson = jsonBody['data'] ?? [];
      
      return postsJson
          .map((json) => PostDTO.fromJson(json))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to get posts: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  /// Get posts filtered by category
  Future<List<PostDTO>> getPostsByCategory(String category) async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts?category=$category');
    
    try {
      final response = await _performRequest(
        () => _httpClient.get(
          uri,
          headers: await _interceptor.getHeaders(),
        ),
      );
      
      final jsonBody = json.decode(response.body);
      final List<dynamic> postsJson = jsonBody['data'] ?? [];
      
      return postsJson
          .map((json) => PostDTO.fromJson(json))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to get posts by category: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  /// Get a single post by id
  Future<PostDTO> getPostById(String id) async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts/$id');
    
    try {
      final response = await _performRequest(
        () => _httpClient.get(
          uri,
          headers: await _interceptor.getHeaders(),
        ),
      );
      
      final jsonBody = json.decode(response.body);
      final postJson = jsonBody['data'];
      
      if (postJson == null) {
        throw const ApiException(
          message: 'Post not found',
          statusCode: ApiException.notFound,
        );
      }
      
      return PostDTO.fromJson(postJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to get post details: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  /// Create a new post
  Future<PostDTO> createPost(PostDTO post) async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts');
    
    try {
      final response = await _performRequest(
        () => _httpClient.post(
          uri,
          headers: await _interceptor.getHeaders(contentType: 'application/json'),
          body: json.encode(post.toJson()),
        ),
      );
      
      final jsonBody = json.decode(response.body);
      final createdPostJson = jsonBody['data'];
      
      if (createdPostJson == null) {
        throw const ApiException(
          message: 'Failed to create post, no data returned',
          statusCode: ApiException.unexpectedError,
        );
      }
      
      return PostDTO.fromJson(createdPostJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to create post: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  /// Update an existing post
  Future<PostDTO> updatePost(String id, PostDTO post) async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts/$id');
    
    try {
      final response = await _performRequest(
        () => _httpClient.put(
          uri,
          headers: await _interceptor.getHeaders(contentType: 'application/json'),
          body: json.encode(post.toJson()),
        ),
      );
      
      final jsonBody = json.decode(response.body);
      final updatedPostJson = jsonBody['data'];
      
      if (updatedPostJson == null) {
        throw const ApiException(
          message: 'Failed to update post, no data returned',
          statusCode: ApiException.unexpectedError,
        );
      }
      
      return PostDTO.fromJson(updatedPostJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to update post: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  /// Delete a post
  Future<void> deletePost(String id) async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts/$id');
    
    try {
      await _performRequest(
        () => _httpClient.delete(
          uri,
          headers: await _interceptor.getHeaders(),
        ),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to delete post: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  /// Like or unlike a post
  Future<void> toggleLikePost(String id) async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts/$id/toggle-like');
    
    try {
      await _performRequest(
        () => _httpClient.post(
          uri,
          headers: await _interceptor.getHeaders(),
        ),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to toggle like: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  /// Get comments for a post
  Future<List<CommentDTO>> getComments(String postId) async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts/$postId/comments');
    
    try {
      final response = await _performRequest(
        () => _httpClient.get(
          uri,
          headers: await _interceptor.getHeaders(),
        ),
      );
      
      final jsonBody = json.decode(response.body);
      final List<dynamic> commentsJson = jsonBody['data'] ?? [];
      
      return commentsJson
          .map((json) => CommentDTO.fromJson(json))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to get comments: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  /// Add a comment to a post
  Future<CommentDTO> addComment(String postId, CommentDTO comment) async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts/$postId/comments');
    
    try {
      final response = await _performRequest(
        () => _httpClient.post(
          uri,
          headers: await _interceptor.getHeaders(contentType: 'application/json'),
          body: json.encode(comment.toJson()),
        ),
      );
      
      final jsonBody = json.decode(response.body);
      final createdCommentJson = jsonBody['data'];
      
      if (createdCommentJson == null) {
        throw const ApiException(
          message: 'Failed to create comment, no data returned',
          statusCode: ApiException.unexpectedError,
        );
      }
      
      return CommentDTO.fromJson(createdCommentJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to create comment: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  /// Like or unlike a comment
  Future<void> toggleLikeComment(String postId, String commentId) async {
    if (!await _networkInfo.isConnected) {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    }
    
    final uri = Uri.parse('$_baseUrl/posts/$postId/comments/$commentId/toggle-like');
    
    try {
      await _performRequest(
        () => _httpClient.post(
          uri,
          headers: await _interceptor.getHeaders(),
        ),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to toggle like on comment: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  Future<http.Response> _performRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      
      if (response.statusCode == 401) {
        // Handle token refresh and retry
        final refreshed = await _interceptor.refreshToken();
        if (refreshed) {
          return await request();
        } else {
          throw const ApiException(
            message: 'Authentication failed',
            statusCode: ApiException.unauthorized,
          );
        }
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        final errorJson = json.decode(response.body);
        throw ApiException(
          message: errorJson['message'] ?? 'Unknown error occurred',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: ApiException.noInternetConnection,
      );
    } on FormatException {
      throw const ApiException(
        message: 'Bad response format',
        statusCode: ApiException.unexpectedError,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Unexpected error: $e',
        statusCode: ApiException.unexpectedError,
      );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;
  
  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });
  
  @override
  String toString() => 'ApiException: $message (Status code: $statusCode)';
} 
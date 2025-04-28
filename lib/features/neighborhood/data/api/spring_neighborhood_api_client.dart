import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:finance_app/core/network/io_client_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:finance_app/core/constants/api_constants.dart';
import 'package:finance_app/core/services/auth_service.dart';
import 'package:finance_app/features/neighborhood/domain/models/post.dart';
import 'package:finance_app/features/neighborhood/domain/models/comment.dart';
import 'package:finance_app/features/neighborhood/domain/models/category.dart' as neighborhood_models;

/// API client for handling neighborhood requests to Spring Boot backend
class SpringNeighborhoodApiClient {
  final http.Client _httpClient;
  final AuthService _authService;
  final String _baseUrl;

  @visibleForTesting
  static http.Client _createHttpClient() {
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    
    return createHttpClient(httpClient);
  }

  SpringNeighborhoodApiClient({
    http.Client? httpClient,
    required AuthService authService,
    String? baseUrl,
  })  : _httpClient = httpClient ?? _createHttpClient(),
        _authService = authService,
        _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all posts with pagination
  Future<List<Post>> getPosts({
    required String location,
    String category = '전체',
    int page = 0,
    int size = 10,
  }) async {
    final queryParams = {
      'location': location,
      'category': category != '전체' ? category : '',
      'page': page.toString(),
      'size': size.toString(),
    };

    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/posts')
        .replace(queryParameters: queryParams);

    final response = await _httpClient.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> posts = jsonResponse['content'] ?? [];
      return posts.map((json) => Post.fromJson(json)).toList();
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to fetch posts',
      );
    }
  }

  /// Get popular posts with pagination
  Future<List<Post>> getPopularPosts({
    required String location,
    int page = 0,
    int size = 10,
  }) async {
    final queryParams = {
      'location': location,
      'page': page.toString(),
      'size': size.toString(),
    };

    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/posts/popular')
        .replace(queryParameters: queryParams);

    final response = await _httpClient.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> posts = jsonResponse['content'] ?? [];
      return posts.map((json) => Post.fromJson(json)).toList();
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to fetch popular posts',
      );
    }
  }

  /// Get a post by ID
  Future<Post> getPostById(String postId) async {
    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/posts/$postId');

    final response = await _httpClient.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Post.fromJson(jsonResponse);
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to fetch post',
      );
    }
  }

  /// Create a new post
  Future<Post> createPost(Post post) async {
    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/posts');

    final response = await _httpClient.post(
      url,
      headers: await _getHeaders(),
      body: json.encode(post.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Post.fromJson(jsonResponse);
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to create post',
      );
    }
  }

  /// Update an existing post
  Future<Post> updatePost(String postId, Post post) async {
    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/posts/$postId');

    final response = await _httpClient.put(
      url,
      headers: await _getHeaders(),
      body: json.encode(post.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Post.fromJson(jsonResponse);
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to update post',
      );
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/posts/$postId');

    final response = await _httpClient.delete(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to delete post',
      );
    }
  }

  /// Like a post
  Future<Post> likePost(String postId) async {
    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/posts/$postId/like');

    final response = await _httpClient.post(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Post.fromJson(jsonResponse);
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to like post',
      );
    }
  }

  /// Get comments for a post
  Future<List<Comment>> getCommentsByPostId(
    String postId, {
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };

    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/posts/$postId/comments')
        .replace(queryParameters: queryParams);

    final response = await _httpClient.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> comments = jsonResponse['content'] ?? [];
      return comments.map((json) => Comment.fromJson(json)).toList();
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to fetch comments',
      );
    }
  }

  /// Create a new comment
  Future<Comment> createComment(Comment comment) async {
    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/posts/${comment.postId}/comments');

    final response = await _httpClient.post(
      url,
      headers: await _getHeaders(),
      body: json.encode(comment.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Comment.fromJson(jsonResponse);
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to create comment',
      );
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/comments/$commentId');

    final response = await _httpClient.delete(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to delete comment',
      );
    }
  }

  /// Like a comment
  Future<Comment> likeComment(String commentId) async {
    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/comments/$commentId/like');

    final response = await _httpClient.post(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Comment.fromJson(jsonResponse);
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to like comment',
      );
    }
  }

  /// Get all categories
  Future<List<neighborhood_models.Category>> getCategories() async {
    final url = Uri.parse('$_baseUrl/api/v1/neighborhood/categories');

    final response = await _httpClient.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> categories = jsonResponse ?? [];
      return categories.map((json) => neighborhood_models.Category.fromJson(json)).toList();
    } else {
      final errorJson = json.decode(utf8.decode(response.bodyBytes));
      throw SpringApiException(
        statusCode: response.statusCode,
        message: errorJson['message'] ?? 'Failed to fetch categories',
      );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

class SpringApiException implements Exception {
  final int statusCode;
  final String message;

  SpringApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'SpringApiException: $statusCode - $message';
} 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:finance_app/core/constants/api_constants.dart';
import 'package:finance_app/features/auth/data/repositories/auth_repository_impl_spring.dart';

/// API client for handling neighborhood requests to Spring Boot backend
class SpringNeighborhoodApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final AuthRepositoryImplSpring _authRepository;

  SpringNeighborhoodApiClient({
    String? baseUrl,
    http.Client? httpClient,
    AuthRepositoryImplSpring? authRepository,
  }) : 
    baseUrl = baseUrl ?? ApiConstants.baseUrl,
    _httpClient = httpClient ?? http.Client(),
    _authRepository = authRepository ?? AuthRepositoryImplSpring();

  /// Get all posts with pagination
  Future<Map<String, dynamic>> getPosts({
    required String location,
    String category = "전체",
    int page = 0,
    int size = 20,
  }) async {
    final token = await _authRepository.getToken();
    final queryParams = {
      'location': location,
      'category': category,
      'page': page.toString(),
      'size': size.toString(),
    };
    
    final response = await _httpClient.get(
      Uri.parse('$baseUrl${ApiConstants.postsEndpoint}').replace(queryParameters: queryParams),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message: 'Failed to load posts',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get popular posts
  Future<Map<String, dynamic>> getPopularPosts({
    required String location,
    int page = 0,
    int size = 10,
  }) async {
    final token = await _authRepository.getToken();
    final queryParams = {
      'location': location,
      'page': page.toString(),
      'size': size.toString(),
    };
    
    final response = await _httpClient.get(
      Uri.parse('$baseUrl${ApiConstants.popularPostsEndpoint}').replace(queryParameters: queryParams),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message: 'Failed to load popular posts',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get a specific post by ID
  Future<Map<String, dynamic>> getPostById(
    String postId,
    String location,
  ) async {
    final token = await _authRepository.getToken();
    final queryParams = {
      'location': location,
    };
    
    final response = await _httpClient.get(
      Uri.parse('$baseUrl${ApiConstants.postsEndpoint}/$postId').replace(queryParameters: queryParams),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message: 'Failed to load post',
        statusCode: response.statusCode,
      );
    }
  }

  /// Create a new post
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    final token = await _authRepository.getToken();
    if (token == null) {
      throw const ApiException(
        message: 'Authentication required',
        statusCode: 401,
      );
    }
    
    final response = await _httpClient.post(
      Uri.parse('$baseUrl${ApiConstants.postsEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(postData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message: 'Failed to create post',
        statusCode: response.statusCode,
      );
    }
  }

  /// Update an existing post
  Future<Map<String, dynamic>> updatePost(String postId, Map<String, dynamic> postData) async {
    final token = await _authRepository.getToken();
    if (token == null) {
      throw const ApiException(
        message: 'Authentication required',
        statusCode: 401,
      );
    }
    
    final response = await _httpClient.put(
      Uri.parse('$baseUrl${ApiConstants.postsEndpoint}/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(postData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message: 'Failed to update post',
        statusCode: response.statusCode,
      );
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    final token = await _authRepository.getToken();
    if (token == null) {
      throw const ApiException(
        message: 'Authentication required',
        statusCode: 401,
      );
    }
    
    final response = await _httpClient.delete(
      Uri.parse('$baseUrl${ApiConstants.postsEndpoint}/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw ApiException(
        message: 'Failed to delete post',
        statusCode: response.statusCode,
      );
    }
  }

  /// Like a post
  Future<Map<String, dynamic>> likePost(String postId) async {
    final token = await _authRepository.getToken();
    if (token == null) {
      throw const ApiException(
        message: 'Authentication required',
        statusCode: 401,
      );
    }
    
    final response = await _httpClient.post(
      Uri.parse('$baseUrl${ApiConstants.postsEndpoint}/$postId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message: 'Failed to like post',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get comments for a post
  Future<List<dynamic>> getCommentsByPostId(String postId, {int page = 0, int size = 20}) async {
    final token = await _authRepository.getToken();
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };
    
    final response = await _httpClient.get(
      Uri.parse('$baseUrl${ApiConstants.commentsEndpoint}/post/$postId').replace(queryParameters: queryParams),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['content'] as List<dynamic>;
    } else {
      throw ApiException(
        message: 'Failed to load comments',
        statusCode: response.statusCode,
      );
    }
  }

  /// Create a new comment
  Future<Map<String, dynamic>> createComment(Map<String, dynamic> commentData) async {
    final token = await _authRepository.getToken();
    if (token == null) {
      throw const ApiException(
        message: 'Authentication required',
        statusCode: 401,
      );
    }
    
    final response = await _httpClient.post(
      Uri.parse('$baseUrl${ApiConstants.commentsEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(commentData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message: 'Failed to create comment',
        statusCode: response.statusCode,
      );
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    final token = await _authRepository.getToken();
    if (token == null) {
      throw const ApiException(
        message: 'Authentication required',
        statusCode: 401,
      );
    }
    
    final response = await _httpClient.delete(
      Uri.parse('$baseUrl${ApiConstants.commentsEndpoint}/$commentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw ApiException(
        message: 'Failed to delete comment',
        statusCode: response.statusCode,
      );
    }
  }

  /// Like a comment
  Future<Map<String, dynamic>> likeComment(String commentId) async {
    final token = await _authRepository.getToken();
    if (token == null) {
      throw const ApiException(
        message: 'Authentication required',
        statusCode: 401,
      );
    }
    
    final response = await _httpClient.post(
      Uri.parse('$baseUrl${ApiConstants.commentsEndpoint}/$commentId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message: 'Failed to like comment',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get all categories
  Future<List<dynamic>> getCategories() async {
    final token = await _authRepository.getToken();
    
    final response = await _httpClient.get(
      Uri.parse('$baseUrl${ApiConstants.categoriesEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw ApiException(
        message: 'Failed to load categories',
        statusCode: response.statusCode,
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
  
  const ApiException({
    required this.message,
    required this.statusCode,
  });
  
  @override
  String toString() => 'ApiException: $message (Status code: $statusCode)';
} 
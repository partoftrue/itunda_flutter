import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exception thrown when API requests fail
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);
  
  // Factory constructor for network exceptions
  factory ApiException.networkException(dynamic error) {
    return ApiException('Network error: ${error.toString()}');
  }

  // Common status codes
  static const int unauthorized = 401;
  static const int notFound = 404;
  static const int serverError = 500;

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status code: $statusCode)' : ''}';
}

/// API client for handling HTTP requests to the backend
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Get the base URL based on the current platform
  static String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8080/api/v1'; // iOS simulator
    } else {
      return 'http://localhost:8080/api/v1'; // Default
    }
  }

  /// Get saved auth token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Save auth token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear auth token (for logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Create headers with optional authentication
  Future<Map<String, String>> _createHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized', response.statusCode);
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        throw ApiException(errorMessage, response.statusCode);
      } catch (e) {
        throw ApiException('Request failed with status: ${response.statusCode}', response.statusCode);
      }
    }
  }

  /// GET request
  Future<dynamic> get(String path, {bool requireAuth = true, Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
      final headers = await _createHeaders(requireAuth: requireAuth);
      
      final response = await _httpClient.get(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkException(e);
    }
  }

  /// POST request
  Future<dynamic> post(String path, {dynamic body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _createHeaders(requireAuth: requireAuth);
      
      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkException(e);
    }
  }

  /// PUT request
  Future<dynamic> put(String path, {dynamic body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _createHeaders(requireAuth: requireAuth);
      
      final response = await _httpClient.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkException(e);
    }
  }

  /// DELETE request
  Future<dynamic> delete(String path, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _createHeaders(requireAuth: requireAuth);
      
      final response = await _httpClient.delete(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkException(e);
    }
  }

  void dispose() {
    _httpClient.close();
  }
} 
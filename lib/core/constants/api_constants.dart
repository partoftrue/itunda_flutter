/// Constants for API endpoints and configurations
class ApiConstants {
  /// Base URL for API
  static const String baseUrl = 'http://api.finance-app.com';
  
  /// Auth endpoints
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String registerEndpoint = '/api/v1/auth/register';
  static const String refreshTokenEndpoint = '/api/v1/auth/refresh';
  
  /// User endpoints
  static const String userProfileEndpoint = '/api/v1/users/profile';
  static const String profileEndpoint = '/api/v1/users/profile';
  static const String usersEndpoint = '/api/v1/users';
  
  /// Neighborhood endpoints
  static const String postsEndpoint = '/api/v1/neighborhood/posts';
  static const String popularPostsEndpoint = '/api/v1/neighborhood/posts/popular';
  static const String categoriesEndpoint = '/api/v1/neighborhood/categories';
  
  /// Timeout durations in milliseconds
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
} 
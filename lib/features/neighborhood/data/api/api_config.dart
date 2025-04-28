/// API configuration for the neighborhood feature
class NeighborhoodApiConfig {
  // Base URL for the API
  static const String baseUrl = 'https://api.finance-app.com/v1/neighborhood';
  
  // Endpoint paths
  static const String posts = '/posts';
  static const String comments = '/comments';
  static const String categories = '/categories';
  static const String likes = '/likes';
  
  // Timeout durations
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Cache configuration
  static const bool enableCache = true;
  static const int cacheMaxAge = 300; // 5 minutes
} 
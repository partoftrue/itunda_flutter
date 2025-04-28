import 'dart:io';

class ApiConfig {
  // Base URL for the API
  static String getBaseUrl() {
    // On Android emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    // On iOS simulator or desktop
    return 'http://localhost:8080/api/v1';
  }
  
  static String get baseUrl => getBaseUrl();
  
  // API endpoints
  static const String authEndpoint = '/auth';
  static const String marketEndpoint = '/market';
  static const String neighborhoodEndpoint = '/neighborhood';
  
  // API timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Pagination defaults
  static const int defaultPageSize = 20;
  
  // Cache configuration
  static const int cacheDuration = 600; // 10 minutes in seconds
} 
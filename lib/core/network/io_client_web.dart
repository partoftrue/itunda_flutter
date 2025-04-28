import 'dart:io';
import 'package:http/http.dart' as http;

/// Creates an HTTP client for Web platform
/// Since HttpClient is not supported on web, just use the default http.Client()
http.Client createPlatformHttpClient(HttpClient httpClient) {
  return http.Client();
} 
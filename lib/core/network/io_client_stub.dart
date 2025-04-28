import 'dart:io';
import 'package:http/http.dart' as http;

/// Stub implementation that will be replaced by the platform-specific one
http.Client createPlatformHttpClient(HttpClient httpClient) {
  throw UnsupportedError(
    'Cannot create an HTTP client without dart:io or dart:html',
  );
} 
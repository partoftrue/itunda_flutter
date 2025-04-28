import 'dart:io';
import 'package:http/http.dart' as http;
import 'io_client_stub.dart'
    if (dart.library.io) 'io_client_io.dart'
    if (dart.library.html) 'io_client_web.dart';

/// Creates a platform-compatible HTTP client
/// 
/// This function serves as a proxy to the appropriate implementation
/// based on the platform (io, web, etc.)
http.Client createHttpClient(HttpClient httpClient) {
  return createPlatformHttpClient(httpClient);
} 
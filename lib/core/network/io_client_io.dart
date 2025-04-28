import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Creates an HTTP client for IO platforms
http.Client createPlatformHttpClient(HttpClient httpClient) {
  return IOClient(httpClient);
} 
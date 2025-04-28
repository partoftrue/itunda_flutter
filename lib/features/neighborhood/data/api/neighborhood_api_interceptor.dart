import 'package:finance_app/core/services/auth_service.dart';
import 'package:finance_app/core/storage/secure_storage.dart';

class NeighborhoodApiInterceptor {
  final AuthService _authService;
  final SecureStorage _secureStorage;
  
  NeighborhoodApiInterceptor({
    required AuthService authService,
    required SecureStorage secureStorage,
  })  : _authService = authService,
        _secureStorage = secureStorage;
  
  /// Get headers for API requests, including auth token if available
  Future<Map<String, String>> getHeaders({String? contentType}) async {
    final headers = <String, String>{};
    
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  /// Handle token refresh when a request fails with 401 Unauthorized
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      
      final response = await _authService.refreshToken(refreshToken);
      
      if (response.accessToken != null && response.refreshToken != null) {
        await _secureStorage.saveAccessToken(response.accessToken!);
        await _secureStorage.saveRefreshToken(response.refreshToken!);
        return true;
      }
      
      return false;
    } catch (e) {
      // On refresh failure, clear tokens and return false
      await _secureStorage.clearTokens();
      return false;
    }
  }
} 
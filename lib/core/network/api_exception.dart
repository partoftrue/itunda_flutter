/// API Exception for handling network errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  // HTTP status codes
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int serverError = 500;
  
  ApiException({
    required this.message,
    required this.statusCode,
  });
  
  @override
  String toString() {
    return 'ApiException: $statusCode - $message';
  }
  
  // Factory constructors for common error types
  static ApiException badRequestException(String message) {
    return ApiException(message: message, statusCode: badRequest);
  }
  
  static ApiException unauthorizedException(String message) {
    return ApiException(message: message, statusCode: unauthorized);
  }
  
  static ApiException forbiddenException(String message) {
    return ApiException(message: message, statusCode: forbidden);
  }
  
  static ApiException notFoundException(String message) {
    return ApiException(message: message, statusCode: notFound);
  }
  
  static ApiException serverErrorException(String message) {
    return ApiException(message: message, statusCode: serverError);
  }
  
  static ApiException networkException(Object e) {
    return ApiException(
      message: 'Network error: ${e.toString()}',
      statusCode: 0,
    );
  }
}

/// Domain-specific exception for the neighborhood feature
class NeighborhoodException implements Exception {
  final String message;
  final NeighborhoodExceptionCode code;
  
  const NeighborhoodException({
    required this.message,
    required this.code,
  });
  
  @override
  String toString() => 'NeighborhoodException: $message (Code: ${code.name})';
}

/// Exception codes for neighborhood domain
enum NeighborhoodExceptionCode {
  noInternet,
  unauthorized,
  notFound,
  serverError,
  unknown,
} 
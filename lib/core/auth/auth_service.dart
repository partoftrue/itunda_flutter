import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

class User {
  final String id;
  final String email;
  final String? name;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    this.name,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImage': profileImage,
    };
  }
}

class AuthService with ChangeNotifier {
  final ApiClient _apiClient;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthService(this._apiClient);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        requireAuth: false,
      );
      
      final token = response['token'];
      await _apiClient.saveToken(token);
      
      await _loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Register a new user
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiClient.post(
        '/auth/register',
        body: {
          'email': email,
          'password': password,
          'name': name,
        },
        requireAuth: false,
      );
      
      final token = response['token'];
      await _apiClient.saveToken(token);
      
      await _loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Load user profile from API
  Future<void> _loadUserProfile() async {
    try {
      final userData = await _apiClient.get('/auth/profile');
      _currentUser = User.fromJson(userData);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      await logout();
      rethrow;
    }
  }

  /// Check if user is authenticated and load profile if needed
  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _apiClient.clearToken();
    _currentUser = null;
    notifyListeners();
  }
} 
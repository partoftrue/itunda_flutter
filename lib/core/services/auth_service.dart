import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';
import 'secure_storage_service.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;

  AuthState({required this.isAuthenticated, this.user});
}

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

/// Service responsible for handling authentication operations
class AuthService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;
  
  // Stream for auth state changes
  final _authStateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authStateChanges => _authStateController.stream;
  
  AuthService([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiClient.getBaseUrl()),
        _secureStorage = SecureStorageService();
  
  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Added for compatibility with MarketplaceApiClient
  Future<String?> getToken() async {
    if (_token != null) return _token;
    return await _secureStorage.read(_tokenKey);
  }
  
  Future<void> init() async {
    try {
      _token = await _secureStorage.read(_tokenKey);
      final userData = await _secureStorage.readJson(_userKey);
      
      if (userData != null) {
        _currentUser = User.fromJson(userData);
      }
      
      // Notify listeners of initial state
      _notifyAuthState();
    } catch (e) {
      _token = null;
      _currentUser = null;
      debugPrint('Error initializing auth service: $e');
    }
  }
  
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
      
      // Store token and save to storage
      final token = response['token'];
      await _apiClient.saveToken(token);
      await _secureStorage.write(_tokenKey, token);
      
      // Get user profile with the new token
      await _loadUserProfile();
      
      _isLoading = false;
      notifyListeners();
      _notifyAuthState();
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
      
      // Store token and save to storage
      final token = response['token'];
      await _apiClient.saveToken(token);
      await _secureStorage.write(_tokenKey, token);
      
      // Get user profile with the new token
      await _loadUserProfile();
      
      _isLoading = false;
      notifyListeners();
      _notifyAuthState();
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
      
      // Save user to secure storage
      await _secureStorage.writeJson(_userKey, _currentUser!.toJson());
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      await logout();
      throw e;
    }
  }
  
  /// Check if user is authenticated and load profile if needed
  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Check if we have a token in storage
      _token = await _secureStorage.read(_tokenKey);
      if (_token == null) {
        _isLoading = false;
        notifyListeners();
        _notifyAuthState();
        return false;
      }
      
      // Restore token to API client
      await _apiClient.saveToken(_token!);
      
      // Try to load user profile
      await _loadUserProfile();
      
      _isLoading = false;
      notifyListeners();
      _notifyAuthState();
      return true;
    } catch (e) {
      await logout();
      _isLoading = false;
      notifyListeners();
      _notifyAuthState();
      return false;
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    // Clear token from storage and memory
    await _secureStorage.delete(_tokenKey);
    await _secureStorage.delete(_userKey);
    await _apiClient.clearToken();
    
    _token = null;
    _currentUser = null;
    
    notifyListeners();
    _notifyAuthState();
  }
  
  // Notify auth state changes
  void _notifyAuthState() {
    _authStateController.add(
      AuthState(
        isAuthenticated: isAuthenticated,
        user: _currentUser,
      ),
    );
  }
  
  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
} 
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';
import '../network/api_client.dart';

class AppProvider with ChangeNotifier {
  
  final StorageService _storageService;
  final ConnectivityService _connectivityService;
  final LocationService _locationService;
  
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool get isOnline => _connectivityService.isOnline;
  
  // Service getters
  
  StorageService get storageService => _storageService;
  ConnectivityService get connectivityService => _connectivityService;
  LocationService get locationService => _locationService;
  
  // Constructor
  AppProvider({
    
    StorageService? storageService,
    ConnectivityService? connectivityService,
    LocationService? locationService,
  }) : 
    
    _storageService = storageService ?? StorageService(),
    _connectivityService = connectivityService ?? ConnectivityService(),
    _locationService = locationService ?? LocationService();
  
  // Initialize all services
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Initialize storage first
      await _storageService.init();
      
      // Initialize auth service
      
      
      // Initialize location service in the background
      _initLocationService();
      
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize app: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(_error);
    }
  }
  
  // Initialize location service (can take longer, so run separately)
  Future<void> _initLocationService() async {
    try {
      await _locationService.init();
    } catch (e) {
      debugPrint('Failed to initialize location service: $e');
      // Don't set error or notify listeners - location is not critical
    }
  }
  
  // Sign in user
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign in failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Sign out user
  Future<bool> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign out failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Register a new user
  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
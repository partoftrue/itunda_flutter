import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LocationAccuracy {
  lowest,
  low,
  medium,
  high,
  best,
  navigation,
}

extension LocationAccuracyExtension on LocationAccuracy {
  geo.LocationAccuracy toGeolocatorAccuracy() {
    switch (this) {
      case LocationAccuracy.lowest:
        return geo.LocationAccuracy.lowest;
      case LocationAccuracy.low:
        return geo.LocationAccuracy.low;
      case LocationAccuracy.medium:
        return geo.LocationAccuracy.medium;
      case LocationAccuracy.high:
        return geo.LocationAccuracy.high;
      case LocationAccuracy.best:
        return geo.LocationAccuracy.best;
      case LocationAccuracy.navigation:
        return geo.LocationAccuracy.bestForNavigation;
    }
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? district;
  final String? city;
  final String? neighborhood;
  final DateTime timestamp;
  
  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.district,
    this.city,
    this.neighborhood,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  @override
  String toString() {
    if (neighborhood != null && district != null) {
      return '$district $neighborhood';
    } else if (district != null) {
      return district!;
    } else if (city != null) {
      return city!;
    } else {
      return '$latitude, $longitude';
    }
  }
  
  // Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'district': district,
      'city': city,
      'neighborhood': neighborhood,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  // Create from JSON
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String?,
      neighborhood: json['neighborhood'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class LocationService with ChangeNotifier {
  LocationData? _currentLocation;
  bool _isLoading = false;
  String? _errorMessage;
  geo.LocationPermission? _permissionStatus;
  LocationAccuracy _accuracy = LocationAccuracy.high;
  final StreamController<LocationData> _locationUpdateController = StreamController<LocationData>.broadcast();
  bool _useCache = true;
  
  // The max age of cached location data (24 hours)
  final Duration _maxCacheAge = const Duration(hours: 24);
  
  // Getters
  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  geo.LocationPermission? get permissionStatus => _permissionStatus;
  Stream<LocationData> get locationUpdates => _locationUpdateController.stream;
  LocationAccuracy get accuracy => _accuracy;
  bool get useCache => _useCache;
  
  // Set location accuracy
  void setAccuracy(LocationAccuracy accuracy) {
    _accuracy = accuracy;
    notifyListeners();
  }
  
  // Enable/disable caching
  void setCacheEnabled(bool enabled) {
    _useCache = enabled;
    notifyListeners();
  }
  
  // Initialize the service and check permissions
  Future<void> init() async {
    _isLoading = true; // Don't notify during initialization
    try {
      // Try to load cached location first
      if (_useCache) {
        final cachedLocation = await _loadCachedLocation();
        if (cachedLocation != null) {
          _currentLocation = cachedLocation;
          _locationUpdateController.add(cachedLocation);
          // Defer notification until after build phase
          Future.microtask(() => notifyListeners());
        }
      }
      
      // Check if location services are enabled
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled. Please enable them in settings.';
        _isLoading = false; // Don't notify during initialization
        return;
      }
      
      // Check permissions
      _permissionStatus = await geo.Geolocator.checkPermission();
      if (_permissionStatus == geo.LocationPermission.denied) {
        _permissionStatus = await geo.Geolocator.requestPermission();
        if (_permissionStatus == geo.LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied.';
          _isLoading = false; // Don't notify during initialization
          return;
        }
      }
      
      if (_permissionStatus == geo.LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied. Please enable them in settings.';
        _isLoading = false; // Don't notify during initialization
        return;
      }
      
      // Get the current position if permissions are granted
      if (_permissionStatus == geo.LocationPermission.whileInUse || 
          _permissionStatus == geo.LocationPermission.always) {
        if (_currentLocation == null || _isCacheExpired(_currentLocation!)) {
          await getCurrentLocation();
        }
      }
    } catch (e) {
      _errorMessage = 'Error initializing location service: $e';
    } finally {
      _isLoading = false; // Don't notify during initialization
      // Defer notification until after build phase
      Future.microtask(() => notifyListeners());
    }
  }
  
  // Get the current location
  Future<LocationData?> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: _accuracy.toGeolocatorAccuracy(),
      );
      
      _currentLocation = await _processPosition(position);
      _locationUpdateController.add(_currentLocation!);
      
      // Cache the location
      if (_useCache) {
        await _cacheLocation(_currentLocation!);
      }
      
      return _currentLocation;
    } catch (e) {
      _errorMessage = 'Failed to get current location: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Process position to get address details
  Future<LocationData> _processPosition(geo.Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // For Korean addresses
        String? neighborhood = placemark.subLocality; // "동" (동 이름)
        String? district = placemark.locality; // "구" (구 이름)
        String? city = placemark.administrativeArea; // "시" (시/도 이름)
        
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: placemark.street,
          neighborhood: neighborhood,
          district: district,
          city: city,
        );
      }
    } catch (e) {
      debugPrint('Error getting address details: $e');
    }
    
    // Return basic location data if geocoding fails
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
  
  // Start listening to location updates
  Future<void> startLocationUpdates({int distanceFilter = 100}) async {
    if (_permissionStatus != geo.LocationPermission.whileInUse && 
        _permissionStatus != geo.LocationPermission.always) {
      return;
    }
    
    geo.LocationSettings locationSettings = geo.LocationSettings(
      accuracy: _accuracy.toGeolocatorAccuracy(),
      distanceFilter: distanceFilter, // Update if user moves X meters
    );
    
    geo.Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((geo.Position position) async {
      _currentLocation = await _processPosition(position);
      _locationUpdateController.add(_currentLocation!);
      
      // Cache the location
      if (_useCache) {
        await _cacheLocation(_currentLocation!);
      }
      
      notifyListeners();
    });
  }
  
  Future<List<LocationData>> searchLocations(String query) async {
    try {
      List<Location> locations = await locationFromAddress(
        query,
      );
      
      List<LocationData> results = [];
      for (var location in locations) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          results.add(LocationData(
            latitude: location.latitude,
            longitude: location.longitude,
            address: placemark.street,
            neighborhood: placemark.subLocality,
            district: placemark.locality,
            city: placemark.administrativeArea,
          ));
        }
      }
      
      return results;
    } catch (e) {
      _errorMessage = 'Error searching locations: $e';
      return [];
    }
  }
  
  // Cache the current location
  Future<void> _cacheLocation(LocationData location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = jsonEncode(location.toJson());
      await prefs.setString('cached_location', locationJson);
    } catch (e) {
      debugPrint('Error caching location: $e');
    }
  }
  
  // Load cached location
  Future<LocationData?> _loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString('cached_location');
      
      if (locationJson != null) {
        final locationData = LocationData.fromJson(jsonDecode(locationJson));
        
        // Check if cache is still valid
        if (!_isCacheExpired(locationData)) {
          return locationData;
        }
      }
    } catch (e) {
      debugPrint('Error loading cached location: $e');
    }
    return null;
  }
  
  // Check if cached location is expired
  bool _isCacheExpired(LocationData location) {
    final now = DateTime.now();
    return now.difference(location.timestamp) > _maxCacheAge;
  }
  
  // Clear cached location
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_location');
    } catch (e) {
      debugPrint('Error clearing location cache: $e');
    }
  }
  
  @override
  void dispose() {
    _locationUpdateController.close();
    super.dispose();
  }
}

// Function to get position from address
Future<geo.Position?> getPositionFromAddress(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return geo.Position(
        latitude: locations.first.latitude,
        longitude: locations.first.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    return null;
  } catch (e) {
    debugPrint('Error getting position from address: $e');
    return null;
  }
}

// Function to get address from position
Future<String?> getAddressFromPosition(geo.Position position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      // Format Korean address differently
      return '${place.administrativeArea ?? ''} ${place.locality ?? ''} ${place.subLocality ?? ''} ${place.thoroughfare ?? ''} ${place.name ?? ''}'.trim();
    }
    return null;
  } catch (e) {
    debugPrint('Error getting address from position: $e');
    return null;
  }
} 
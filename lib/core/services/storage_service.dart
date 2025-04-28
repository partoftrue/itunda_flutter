import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling persistent storage operations
class StorageService {
  late SharedPreferences _prefs;
  bool _initialized = false;
  
  // Initialize the storage service
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }
  
  // Check if the storage service is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  // Get a string value
  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs.getString(key);
  }

  // Save a string value
  Future<bool> saveString(String key, String value) async {
    await _ensureInitialized();
    return await _prefs.setString(key, value);
  }

  // Get a boolean value
  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _prefs.getBool(key);
  }

  // Save a boolean value
  Future<bool> saveBool(String key, bool value) async {
    await _ensureInitialized();
    return await _prefs.setBool(key, value);
  }

  // Get an integer value
  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _prefs.getInt(key);
  }

  // Save an integer value
  Future<bool> saveInt(String key, int value) async {
    await _ensureInitialized();
    return await _prefs.setInt(key, value);
  }

  // Get a double value
  Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    return _prefs.getDouble(key);
  }

  // Save a double value
  Future<bool> saveDouble(String key, double value) async {
    await _ensureInitialized();
    return await _prefs.setDouble(key, value);
  }

  // Get a list of strings
  Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    return _prefs.getStringList(key);
  }

  // Save a list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    await _ensureInitialized();
    return await _prefs.setStringList(key, value);
  }

  // Get a map (stored as a JSON string)
  Future<Map<String, dynamic>?> getMap(String key) async {
    await _ensureInitialized();
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    
    try {
      return json.decode(jsonString);
    } catch (e) {
      return null;
    }
  }

  // Save a map (stored as a JSON string)
  Future<bool> saveMap(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    final jsonString = json.encode(value);
    return await _prefs.setString(key, jsonString);
  }

  // Get an object (stored as a JSON string)
  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) async {
    await _ensureInitialized();
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    
    try {
      final jsonMap = json.decode(jsonString);
      return fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  // Save an object (stored as a JSON string)
  Future<bool> saveObject(String key, Object value) async {
    await _ensureInitialized();
    final jsonString = json.encode(value);
    return await _prefs.setString(key, jsonString);
  }

  // Check if a key exists
  Future<bool> hasKey(String key) async {
    await _ensureInitialized();
    return _prefs.containsKey(key);
  }

  // Remove a key
  Future<bool> delete(String key) async {
    await _ensureInitialized();
    return await _prefs.remove(key);
  }

  // Clear all data
  Future<bool> clear() async {
    await _ensureInitialized();
    return await _prefs.clear();
  }
} 
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service for securely storing sensitive information.
class SecureStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _storage;
  
  /// Creates a new instance of [SecureStorage].
  SecureStorage({FlutterSecureStorage? storage}) 
      : _storage = storage ?? const FlutterSecureStorage();
  
  /// Writes a value to secure storage.
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  /// Reads a value from secure storage.
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }
  
  /// Deletes a value from secure storage.
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
  
  /// Deletes all values from secure storage.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
  
  /// Writes a Map or List object to secure storage as a JSON string.
  Future<void> writeObject(String key, Object value) async {
    final jsonString = jsonEncode(value);
    await write(key, jsonString);
  }
  
  /// Reads a JSON string from secure storage and converts it to a Map.
  Future<Map<String, dynamic>?> readObject(String key) async {
    final jsonString = await read(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  /// Reads a JSON string from secure storage and converts it to a List.
  Future<List<dynamic>?> readList(String key) async {
    final jsonString = await read(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as List<dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  // Get saved token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // Save auth token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  // Get saved user data (JSON string)
  Future<String?> getUser() async {
    return await _storage.read(key: _userKey);
  }
  
  // Save user data as JSON string
  Future<void> saveUser(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }
  
  // Delete token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  // Delete user data
  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }
  
  // Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
} 
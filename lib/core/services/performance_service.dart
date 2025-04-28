import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceService {
  final SharedPreferences _prefs;
  static const String _cacheKey = 'performance_cache';
  final Map<String, dynamic> _memoryCache = {};

  PerformanceService(this._prefs);

  // Cache data with expiration
  Future<void> cacheData(String key, dynamic data, {Duration? expiration}) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': expiration?.inMilliseconds,
    };

    _memoryCache[key] = cacheEntry;
    
    final allCache = _prefs.getString(_cacheKey);
    final Map<String, dynamic> cacheMap = allCache != null 
        ? Map<String, dynamic>.from(json.decode(allCache))
        : {};
    
    cacheMap[key] = cacheEntry;
    await _prefs.setString(_cacheKey, json.encode(cacheMap));
  }

  // Get cached data if not expired
  T? getCachedData<T>(String key) {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key];
      if (!_isExpired(entry)) {
        return entry['data'] as T;
      }
    }

    // Check persistent cache
    final allCache = _prefs.getString(_cacheKey);
    if (allCache != null) {
      final cacheMap = Map<String, dynamic>.from(json.decode(allCache));
      if (cacheMap.containsKey(key)) {
        final entry = cacheMap[key];
        if (!_isExpired(entry)) {
          _memoryCache[key] = entry; // Update memory cache
          return entry['data'] as T;
        }
      }
    }

    return null;
  }

  bool _isExpired(Map<String, dynamic> entry) {
    final timestamp = entry['timestamp'] as int;
    final expiration = entry['expiration'] as int?;
    
    if (expiration == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp > expiration;
  }

  // Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final allCache = _prefs.getString(_cacheKey);
    if (allCache != null) {
      final cacheMap = Map<String, dynamic>.from(json.decode(allCache));
      cacheMap.removeWhere((key, value) => _isExpired(value));
      await _prefs.setString(_cacheKey, json.encode(cacheMap));
    }
    _memoryCache.removeWhere((key, value) => _isExpired(value));
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await _prefs.remove(_cacheKey);
    _memoryCache.clear();
  }
} 
import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class FeatureDiscoveryService {
  final SharedPreferences _prefs;
  static const String _featureKey = 'feature_discovery';
  
  FeatureDiscoveryService(this._prefs);

  Future<bool> shouldShowFeature(String featureId) async {
    final features = _prefs.getStringList(_featureKey) ?? [];
    return !features.contains(featureId);
  }

  Future<void> markFeatureAsSeen(String featureId) async {
    final features = _prefs.getStringList(_featureKey) ?? [];
    if (!features.contains(featureId)) {
      features.add(featureId);
      await _prefs.setStringList(_featureKey, features);
    }
  }

  Future<void> resetFeatureDiscovery() async {
    await _prefs.remove(_featureKey);
  }

  // Feature IDs
  static const String quickPayFeature = 'quick_pay';
  static const String marketplaceFeature = 'marketplace';
  static const String neighborhoodFeature = 'neighborhood';
  static const String chatFeature = 'chat';
  static const String profileFeature = 'profile';
} 
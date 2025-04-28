import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _notificationKey = 'notifications';
  bool _isEnabled = true;
  
  NotificationService(this._prefs) {
    _loadNotificationSettings();
  }

  bool get isEnabled => _isEnabled;

  Future<void> _loadNotificationSettings() async {
    _isEnabled = _prefs.getBool(_notificationKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _isEnabled = value;
    await _prefs.setBool(_notificationKey, value);
    notifyListeners();
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isEnabled) return;
    
    // For now, just print to console
    debugPrint('Notification: $title - $body');
    
    // In a real app, you would implement actual notification display here
    // This could be done with Firebase Cloud Messaging or another notification service
  }

  Future<void> handleNotificationTap(String payload) async {
    // TODO: Implement notification tap handling
    debugPrint('Notification tapped with payload: $payload');
  }
} 
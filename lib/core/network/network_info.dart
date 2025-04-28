import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Utility class to check network connectivity
class NetworkInfo {
  final Connectivity _connectivity;
  
  NetworkInfo({Connectivity? connectivity}) 
      : _connectivity = connectivity ?? Connectivity();
  
  /// Check if the device is connected to the internet
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  /// Stream of connectivity changes
  Stream<ConnectivityResult> get onConnectivityChanged {
    // Handle both single connectivity result and potential list of results
    return _connectivity.onConnectivityChanged.map((event) {
      if (event is List<ConnectivityResult> && event.isNotEmpty) {
        return event.first;
      }
      return event as ConnectivityResult;
    });
  }
} 
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import 'notification_service.dart';
import 'theme_service.dart';
import 'auth_service.dart';
import '../../features/neighborhood/data/neighborhood_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(prefs);
  
  // Register ApiClient
  final apiClient = ApiClient(baseUrl: ApiClient.getBaseUrl());
  serviceLocator.registerSingleton<ApiClient>(apiClient);
  
  // Register services
  serviceLocator.registerSingleton<NotificationService>(
    NotificationService(prefs),
  );
  
  serviceLocator.registerSingleton<ThemeService>(ThemeService(prefs));
}
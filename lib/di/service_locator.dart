import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../core/auth/auth_service.dart';
import '../features/neighborhood/data/neighborhood_service.dart';

final getIt = GetIt.instance;

/// Setup service locator for dependency injection
void setupServiceLocator() {
  // API Client
  getIt.registerLazySingleton(() => ApiClient(
    baseUrl: ApiClient.getBaseUrl(),
  ));
  
  // Services
  getIt.registerLazySingleton(() => AuthService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => NeighborhoodService(getIt<ApiClient>()));
} 
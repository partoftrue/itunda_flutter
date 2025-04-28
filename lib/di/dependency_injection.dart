import 'package:finance_app/features/neighborhood/data/api/spring_neighborhood_api_client.dart';
import 'package:finance_app/features/neighborhood/data/repositories/spring_neighborhood_repository.dart';

void setupDependencies() {
  // Neighborhood Feature
  getIt.registerLazySingleton<SpringNeighborhoodApiClient>(
    () => SpringNeighborhoodApiClient(
      client: getIt<http.Client>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  
  getIt.registerLazySingleton<NeighborhoodRepository>(
    () => SpringNeighborhoodRepository(
      apiClient: getIt<SpringNeighborhoodApiClient>(),
    ),
  );
} 
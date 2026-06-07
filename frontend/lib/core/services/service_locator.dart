import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import 'token_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<TokenService>(() => TokenService());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiClient>(), getIt<TokenService>()),
  );
}

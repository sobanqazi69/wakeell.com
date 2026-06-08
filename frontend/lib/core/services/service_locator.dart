import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import 'token_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/admin/data/repositories/admin_repository.dart';
import '../../features/lawyer/data/repositories/lawyer_repository.dart';
import '../../features/booking/data/repositories/booking_repository.dart';
import '../../features/session/data/repositories/session_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<TokenService>(() => TokenService());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<TokenService>()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiClient>(), getIt<TokenService>()),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<LawyerRepository>(
    () => LawyerRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepository(getIt<ApiClient>()),
  );
}

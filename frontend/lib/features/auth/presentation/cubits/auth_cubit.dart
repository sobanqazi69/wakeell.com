import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/socket_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  static const String _tag = 'AuthCubit';

  final AuthRepository _repo;
  UserModel? currentUser;

  AuthCubit(this._repo) : super(const AuthInitial());

  /// Called on app startup — checks if a valid token exists.
  Future<void> checkAuthStatus() async {
    try {
      if (isClosed) return;
      emit(const AuthLoading());

      final user = await _repo.getMe();

      if (isClosed) return;
      if (user != null) {
        currentUser = user;
        emit(AuthAuthenticated(user));
        PushNotificationService.init(getIt<ApiClient>());
      _connectSocket();
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      DebugLogger.error(_tag, 'checkAuthStatus: $e');
      if (!isClosed) emit(const AuthUnauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      if (isClosed) return;
      emit(const AuthLoading());

      final user = await _repo.login(email: email, password: password);
      currentUser = user;
      if (!isClosed) emit(AuthAuthenticated(user));

      // Initialize push notifications now that we have a valid auth token
      PushNotificationService.init(getIt<ApiClient>());
      _connectSocket();
    } on AuthException catch (e) {
      DebugLogger.error(_tag, 'login AuthException: ${e.message}');
      if (!isClosed) emit(AuthError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'login error: $e');
      if (!isClosed) emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> registerClient({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? location,
    String? jurisdiction,
  }) async {
    try {
      if (isClosed) return;
      emit(const AuthLoading());

      final user = await _repo.registerClient(
        name: name,
        email: email,
        password: password,
        phone: phone,
        location: location,
        jurisdiction: jurisdiction,
      );
      currentUser = user;
      if (!isClosed) emit(AuthAuthenticated(user));

      PushNotificationService.init(getIt<ApiClient>());
      _connectSocket();
    } on AuthException catch (e) {
      DebugLogger.error(_tag, 'registerClient AuthException: ${e.message}');
      if (!isClosed) emit(AuthError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'registerClient error: $e');
      if (!isClosed) emit(const AuthError('Registration failed. Please try again.'));
    }
  }

  Future<void> registerLawyer({
    required String name,
    required String email,
    required String password,
    required String barLicense,
    String? phone,
    String? bio,
    XFile? photo,
  }) async {
    try {
      if (isClosed) return;
      emit(const AuthLoading());

      await _repo.registerLawyer(
        name: name,
        email: email,
        password: password,
        barLicense: barLicense,
        phone: phone,
        bio: bio,
        photo: photo,
      );

      if (!isClosed) emit(const AuthLawyerPending());
    } on AuthException catch (e) {
      DebugLogger.error(_tag, 'registerLawyer AuthException: ${e.message}');
      if (!isClosed) emit(AuthError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'registerLawyer error: $e');
      if (!isClosed) emit(const AuthError('Registration failed. Please try again.'));
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
      currentUser = null;
      if (!isClosed) emit(const AuthUnauthenticated());
    } catch (e) {
      DebugLogger.error(_tag, 'logout error: $e');
      if (!isClosed) emit(const AuthUnauthenticated());
    }
  }

  void updateUser(UserModel user) {
    currentUser = user;
    if (!isClosed) emit(AuthAuthenticated(user));
  }

  Future<void> uploadAvatar(XFile photo) async {
    try {
      final user = await _repo.uploadAvatar(photo);
      currentUser = user;
      if (!isClosed) emit(AuthAuthenticated(user));
    } on AuthException {
      rethrow;
    } catch (e) {
      DebugLogger.error(_tag, 'uploadAvatar unexpected: $e');
      rethrow;
    }
  }

  Future<void> _connectSocket() async {
    try {
      final token = await getIt<TokenService>().getToken();
      if (token != null) {
        getIt<SocketService>().connect(token);
      }
    } catch (e) {
      DebugLogger.error(_tag, '_connectSocket: $e');
    }
  }
}

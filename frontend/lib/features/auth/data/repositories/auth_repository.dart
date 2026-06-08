import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../../../core/utils/map_utils.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class AuthRepository {
  static const String _tag = 'AuthRepository';

  final ApiClient _api;
  final TokenService _token;

  AuthRepository(this._api, this._token);

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      final token = handleNullableStringKey(data, 'token');
      if (token == null) throw const AuthException('No token received from server');

      await _token.saveToken(token);

      final userJson = handleNullableMapKey(data, 'user');
      if (userJson == null) throw const AuthException('Invalid response from server');

      DebugLogger.log(_tag, 'Login success: ${userJson['email']}');
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'Login DioException: ${e.message}');
      final message = _extractMessage(e) ?? 'Login failed. Please check your connection.';
      throw AuthException(message);
    } catch (e) {
      if (e is AuthException) rethrow;
      DebugLogger.error(_tag, 'Login error: $e');
      throw const AuthException('An unexpected error occurred. Please try again.');
    }
  }

  Future<UserModel> registerClient({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? location,
    String? jurisdiction,
  }) async {
    try {
      final response = await _api.post('/auth/register', data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': 'client',
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (location != null && location.isNotEmpty) 'location': location,
        if (jurisdiction != null && jurisdiction.isNotEmpty) 'jurisdiction': jurisdiction,
      });

      final data = response.data as Map<String, dynamic>;
      final token = handleNullableStringKey(data, 'token');
      if (token == null) throw const AuthException('Registration failed: no token received');

      await _token.saveToken(token);

      final userJson = handleNullableMapKey(data, 'user');
      if (userJson == null) throw const AuthException('Invalid response from server');

      DebugLogger.log(_tag, 'Client registered: ${userJson['email']}');
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'Register DioException: ${e.message}');
      final message = _extractMessage(e) ?? 'Registration failed. Please try again.';
      throw AuthException(message);
    } catch (e) {
      if (e is AuthException) rethrow;
      DebugLogger.error(_tag, 'Register error: $e');
      throw const AuthException('An unexpected error occurred. Please try again.');
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
      final fields = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'barLicense': barLicense.trim(),
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (bio != null && bio.isNotEmpty) 'bio': bio,
      };

      dynamic payload;
      if (photo != null) {
        payload = FormData.fromMap({
          ...fields,
          'avatar': await MultipartFile.fromFile(photo.path, filename: photo.name),
        });
      } else {
        payload = fields;
      }

      await _api.post('/auth/register/lawyer', data: payload);
      DebugLogger.log(_tag, 'Lawyer registration submitted: $email');
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'Lawyer register DioException: ${e.message}');
      final message = _extractMessage(e) ?? 'Registration failed. Please try again.';
      throw AuthException(message);
    } catch (e) {
      if (e is AuthException) rethrow;
      DebugLogger.error(_tag, 'Lawyer register error: $e');
      throw const AuthException('An unexpected error occurred. Please try again.');
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final hasToken = await _token.hasToken();
      if (!hasToken) return null;

      final response = await _api.get('/auth/me');
      final data = response.data as Map<String, dynamic>;
      final userJson = handleNullableMapKey(data, 'user');
      if (userJson == null) return null;

      DebugLogger.log(_tag, 'getMe success');
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getMe DioException: ${e.message}');
      return null;
    } catch (e) {
      DebugLogger.error(_tag, 'getMe error: $e');
      return null;
    }
  }

  Future<UserModel> updateMe({
    String? name,
    String? phone,
    String? location,
    String? jurisdiction,
  }) async {
    try {
      final res = await _api.patch('/auth/me', data: {
        // ignore: use_null_aware_elements
        if (name != null) 'name': name.trim(),
        // ignore: use_null_aware_elements
        if (phone != null) 'phone': phone.trim(),
        // ignore: use_null_aware_elements
        if (location != null) 'location': location,
        // ignore: use_null_aware_elements
        if (jurisdiction != null) 'jurisdiction': jurisdiction,
      });
      final data = res.data as Map<String, dynamic>;
      final userJson = handleNullableMapKey(data, 'user') ?? data;
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'updateMe: ${e.message}');
      throw AuthException(_extractMessage(e) ?? 'Failed to update profile');
    } catch (e) {
      if (e is AuthException) rethrow;
      DebugLogger.error(_tag, 'updateMe unexpected: $e');
      throw const AuthException('Failed to update profile');
    }
  }

  Future<UserModel> uploadAvatar(XFile photo) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(photo.path, filename: photo.name),
      });
      final res = await _api.patch('/auth/me/avatar', data: formData);
      final data = res.data as Map<String, dynamic>;
      final userJson = handleNullableMapKey(data, 'user') ?? data;
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'uploadAvatar: ${e.message}');
      throw AuthException(_extractMessage(e) ?? 'Failed to upload avatar');
    } catch (e) {
      if (e is AuthException) rethrow;
      DebugLogger.error(_tag, 'uploadAvatar unexpected: $e');
      throw const AuthException('Failed to upload avatar');
    }
  }

  Future<void> logout() async {
    await _token.clearToken();
    DebugLogger.log(_tag, 'Logged out');
  }

  String? _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) return data['message']?.toString();
      return null;
    } catch (_) {
      return null;
    }
  }
}

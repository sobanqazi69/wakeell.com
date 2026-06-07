import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/debug_logger.dart';

class TokenService {
  static const String _tag = 'TokenService';
  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      DebugLogger.log(_tag, 'Token saved');
    } catch (e) {
      DebugLogger.error(_tag, 'Failed to save token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      DebugLogger.error(_tag, 'Failed to read token: $e');
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      DebugLogger.log(_tag, 'Token cleared');
    } catch (e) {
      DebugLogger.error(_tag, 'Failed to clear token: $e');
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/debug_logger.dart';
import '../models/session_token_model.dart';

class SessionException implements Exception {
  final String message;
  const SessionException(this.message);
}

class SessionRepository {
  static const _tag = 'SessionRepository';
  final ApiClient _api;

  const SessionRepository(this._api);

  Future<void> endSession(int bookingId) async {
    try {
      await _api.patch('/sessions/$bookingId/end', data: {});
    } catch (e) {
      DebugLogger.error(_tag, 'endSession: $e');
    }
  }

  Future<void> writeSummary(int bookingId, String summary) async {
    try {
      await _api.patch('/sessions/$bookingId/summary',
          data: {'adviceSummary': summary});
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'writeSummary: ${e.message}');
      throw SessionException(
          (e.response?.data is Map ? e.response?.data['message'] : null) ??
              'Failed to save summary');
    } catch (e) {
      DebugLogger.error(_tag, 'writeSummary unexpected: $e');
      throw const SessionException('Failed to save summary');
    }
  }

  Future<SessionTokenModel> joinToken(int bookingId) async {
    try {
      final res = await _api.post('/sessions/$bookingId/token');
      final data = res.data as Map<String, dynamic>;
      return SessionTokenModel.fromJson(data);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'joinToken: ${e.message}');
      final msg = (e.response?.data is Map) ? e.response?.data['message'] : null;
      throw SessionException(msg ?? 'Failed to join session');
    } catch (e) {
      DebugLogger.error(_tag, 'joinToken unexpected: $e');
      throw const SessionException('Failed to join session');
    }
  }
}

import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/debug_logger.dart';
import '../../../../../core/utils/map_utils.dart';
import '../models/pending_lawyer_model.dart';

class AdminException implements Exception {
  final String message;
  const AdminException(this.message);
}

class AdminRepository {
  static const _tag = 'AdminRepository';
  final ApiClient _api;

  const AdminRepository(this._api);

  Future<AdminStatsModel> getStats() async {
    try {
      final res = await _api.get('/admin/stats');
      final data = res.data as Map<String, dynamic>;
      return AdminStatsModel.fromJson(data);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getStats: ${e.message}');
      throw AdminException(_extractMessage(e) ?? 'Failed to load stats');
    } catch (e) {
      DebugLogger.error(_tag, 'getStats unexpected: $e');
      throw const AdminException('Failed to load stats');
    }
  }

  Future<List<PendingLawyerModel>> getPendingLawyers() async {
    try {
      final res = await _api.get('/admin/lawyers/pending');
      final data = res.data as Map<String, dynamic>;
      final list = handleNullableListKey(data, 'lawyers') ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(PendingLawyerModel.fromJson)
          .toList();
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getPendingLawyers: ${e.message}');
      throw AdminException(_extractMessage(e) ?? 'Failed to load pending lawyers');
    } catch (e) {
      DebugLogger.error(_tag, 'getPendingLawyers unexpected: $e');
      throw const AdminException('Failed to load pending lawyers');
    }
  }

  Future<void> verifyLawyer({
    required int lawyerId,
    required String status, // 'approved' | 'rejected'
    String? adminNote,
  }) async {
    try {
      await _api.patch('/admin/lawyers/$lawyerId/verify', data: {
        'status': status,
        if (adminNote != null && adminNote.isNotEmpty) 'adminNote': adminNote,
      });
      DebugLogger.log(_tag, 'Lawyer $lawyerId → $status');
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'verifyLawyer: ${e.message}');
      throw AdminException(_extractMessage(e) ?? 'Action failed');
    } catch (e) {
      DebugLogger.error(_tag, 'verifyLawyer unexpected: $e');
      throw const AdminException('Action failed');
    }
  }

  String? _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) return data['message'] as String?;
    } catch (_) {}
    return null;
  }
}

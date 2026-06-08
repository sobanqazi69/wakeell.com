import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/debug_logger.dart';
import '../../../../../core/utils/map_utils.dart';
import '../models/lawyer_model.dart';

class LawyerException implements Exception {
  final String message;
  const LawyerException(this.message);
}

class LawyerRepository {
  static const _tag = 'LawyerRepository';
  final ApiClient _api;

  const LawyerRepository(this._api);

  Future<List<LawyerModel>> getLawyers({
    String? search,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _api.get('/lawyers', params: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category != 'All') 'category': category,
        'page': page,
        'limit': limit,
      });
      final data = res.data as Map<String, dynamic>;
      final list = handleNullableListKey(data, 'lawyers') ?? [];
      return list.whereType<Map<String, dynamic>>().map(LawyerModel.fromJson).toList();
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getLawyers: ${e.message}');
      throw LawyerException(_msg(e) ?? 'Failed to load lawyers');
    } catch (e) {
      DebugLogger.error(_tag, 'getLawyers unexpected: $e');
      throw const LawyerException('Failed to load lawyers');
    }
  }

  Future<LawyerModel> getLawyerById(int id) async {
    try {
      final res = await _api.get('/lawyers/$id');
      final data = res.data as Map<String, dynamic>;
      final profile = handleNullableMapKey(data, 'profile') ?? data;
      return LawyerModel.fromJson(profile);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getLawyerById: ${e.message}');
      throw LawyerException(_msg(e) ?? 'Failed to load profile');
    } catch (e) {
      DebugLogger.error(_tag, 'getLawyerById unexpected: $e');
      throw const LawyerException('Failed to load profile');
    }
  }

  String? _msg(DioException e) {
    try {
      final d = e.response?.data;
      if (d is Map) return d['message'] as String?;
    } catch (_) {}
    return null;
  }
}

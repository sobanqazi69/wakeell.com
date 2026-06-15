import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/debug_logger.dart';
import '../../../../../core/utils/map_utils.dart';
import '../models/lawyer_model.dart';
import '../models/review_model.dart';

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
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _api.get('/lawyers', params: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category != 'All') 'category': category,
        if (location != null && location.isNotEmpty) 'location': location,
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

  Future<LawyerModel> getMyProfile() async {
    try {
      final res = await _api.get('/lawyers/me');
      final data = res.data as Map<String, dynamic>;
      final profile = handleNullableMapKey(data, 'profile') ?? data;
      return LawyerModel.fromJson(profile);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getMyProfile: ${e.message}');
      throw LawyerException(_msg(e) ?? 'Failed to load profile');
    } catch (e) {
      DebugLogger.error(_tag, 'getMyProfile unexpected: $e');
      throw const LawyerException('Failed to load profile');
    }
  }

  Future<LawyerModel> updateMyProfile({
    String? bio,
    List<String>? specializations,
    List<String>? languages,
    double? hourlyRate,
    int? experience,
  }) async {
    try {
      final res = await _api.patch('/lawyers/profile', data: {
        // ignore: use_null_aware_elements
        if (bio != null) 'bio': bio,
        // ignore: use_null_aware_elements
        if (specializations != null) 'specializations': specializations,
        // ignore: use_null_aware_elements
        if (languages != null) 'languages': languages,
        // ignore: use_null_aware_elements
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        // ignore: use_null_aware_elements
        if (experience != null) 'experience': experience,
      });
      final data = res.data as Map<String, dynamic>;
      final profile = handleNullableMapKey(data, 'profile') ?? data;
      return LawyerModel.fromJson(profile);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'updateMyProfile: ${e.message}');
      throw LawyerException(_msg(e) ?? 'Failed to update profile');
    } catch (e) {
      DebugLogger.error(_tag, 'updateMyProfile unexpected: $e');
      throw const LawyerException('Failed to update profile');
    }
  }

  Future<void> setAvailability(List<Map<String, dynamic>> entries) async {
    try {
      await _api.patch('/lawyers/availability', data: {'availability': entries});
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'setAvailability: ${e.message}');
      throw LawyerException(_msg(e) ?? 'Failed to save availability');
    } catch (e) {
      DebugLogger.error(_tag, 'setAvailability unexpected: $e');
      throw const LawyerException('Failed to save availability');
    }
  }

  Future<Map<String, List<String>>> getAvailability(int lawyerId) async {
    try {
      final res = await _api.get('/lawyers/$lawyerId/availability');
      final data = res.data as Map<String, dynamic>;
      final list = handleNullableListKey(data, 'availability') ?? [];
      DebugLogger.log(_tag, 'getAvailability($lawyerId): raw list length = ${list.length}');
      final Map<String, List<String>> result = {};
      for (final item in list.whereType<Map<String, dynamic>>()) {
        final date = handleNullableStringKey(item, 'date') ?? '';
        if (date.isEmpty) continue;

        // MySQL JSON columns may arrive as a raw String — decode if needed
        final slotsRaw = item['slots'];
        List<dynamic> rawSlots;
        if (slotsRaw is List) {
          rawSlots = slotsRaw;
        } else if (slotsRaw is String && slotsRaw.isNotEmpty) {
          try {
            final decoded = jsonDecode(slotsRaw);
            rawSlots = decoded is List ? decoded : [];
          } catch (_) {
            rawSlots = [];
          }
        } else {
          rawSlots = [];
        }

        final slotList = rawSlots.whereType<String>().toList()..sort();
        DebugLogger.log(_tag, '  entry: date="$date" slotsRaw type=${slotsRaw.runtimeType} parsed=$slotList');
        if (slotList.isNotEmpty) result[date] = slotList;
      }
      DebugLogger.log(_tag, 'getAvailability result: $result');
      return result;
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getAvailability: ${e.message}');
      throw LawyerException(_msg(e) ?? 'Failed to load availability');
    } catch (e) {
      DebugLogger.error(_tag, 'getAvailability unexpected: $e');
      throw const LawyerException('Failed to load availability');
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

  Future<List<ReviewModel>> getLawyerReviews(int lawyerId) async {
    try {
      final res = await _api.get('/reviews/lawyer/$lawyerId');
      final data = res.data as Map<String, dynamic>;
      final list = handleNullableListKey(data, 'reviews') ?? [];
      return list.whereType<Map<String, dynamic>>().map(ReviewModel.fromJson).toList();
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getLawyerReviews: ${e.message}');
      return [];
    } catch (e) {
      DebugLogger.error(_tag, 'getLawyerReviews unexpected: $e');
      return [];
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

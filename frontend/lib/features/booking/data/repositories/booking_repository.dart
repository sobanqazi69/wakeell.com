import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/debug_logger.dart';
import '../../../../../core/utils/map_utils.dart';
import '../models/booking_model.dart';

class BookingException implements Exception {
  final String message;
  const BookingException(this.message);
}

class BookingRepository {
  static const _tag = 'BookingRepository';
  final ApiClient _api;
  const BookingRepository(this._api);

  Future<List<BookingModel>> getMyBookings() async {
    try {
      final res = await _api.get('/bookings');
      final data = res.data as Map<String, dynamic>;
      final list = handleNullableListKey(data, 'bookings') ?? [];
      return list.whereType<Map<String, dynamic>>().map(BookingModel.fromJson).toList();
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getMyBookings: ${e.message}');
      throw BookingException(_msg(e) ?? 'Failed to load bookings');
    } catch (e) {
      DebugLogger.error(_tag, 'getMyBookings unexpected: $e');
      throw const BookingException('Failed to load bookings');
    }
  }

  Future<BookingModel> createBooking({
    required int lawyerId,
    required String date,
    required String timeSlot,
    required String sessionType,
    required String category,
    required String caseBrief,
    int duration = 60,
  }) async {
    try {
      final res = await _api.post('/bookings', data: {
        'lawyerId': lawyerId,
        'date': date,
        'timeSlot': timeSlot,
        'sessionType': sessionType,
        'category': category,
        'caseBrief': caseBrief,
        'duration': duration,
      });
      final data = res.data as Map<String, dynamic>;
      final booking = handleNullableMapKey(data, 'booking') ?? data;
      return BookingModel.fromJson(booking);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'createBooking: ${e.message}');
      throw BookingException(_msg(e) ?? 'Failed to create booking');
    } catch (e) {
      DebugLogger.error(_tag, 'createBooking unexpected: $e');
      throw const BookingException('Failed to create booking');
    }
  }

  Future<void> respond(int bookingId, String status) async {
    try {
      await _api.patch('/bookings/$bookingId/respond', data: {'status': status});
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'respond: ${e.message}');
      throw BookingException(_msg(e) ?? 'Failed to update booking');
    } catch (e) {
      DebugLogger.error(_tag, 'respond unexpected: $e');
      throw const BookingException('Failed to update booking');
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      await _api.patch('/bookings/$bookingId/cancel', data: {});
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'cancelBooking: ${e.message}');
      throw BookingException(_msg(e) ?? 'Failed to cancel booking');
    } catch (e) {
      DebugLogger.error(_tag, 'cancelBooking unexpected: $e');
      throw const BookingException('Failed to cancel booking');
    }
  }

  String? _msg(DioException e) {
    try { final d = e.response?.data; if (d is Map) return d['message'] as String?; } catch (_) {}
    return null;
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking_model.dart';
import 'lawyer_bookings_state.dart';

class LawyerBookingsCubit extends Cubit<LawyerBookingsState> {
  static const _tag = 'LawyerBookingsCubit';
  final BookingRepository _repo;
  List<BookingModel> _all = [];
  String _filter = 'all';

  LawyerBookingsCubit(this._repo) : super(const LawyerBookingsInitial());

  Future<void> load() async {
    try {
      if (!isClosed) emit(const LawyerBookingsLoading());
      _all = await _repo.getMyBookings();
      _emit();
    } on BookingException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerBookingsError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'load: $e');
      if (!isClosed) emit(const LawyerBookingsError('Failed to load bookings'));
    }
  }

  Future<void> refresh() => load();

  List<BookingModel> get completedBookings {
    // One entry per client — keep the most recent completed booking.
    final byClient = <int, BookingModel>{};
    for (final b in _all.where((b) => b.status == 'completed')) {
      final existing = byClient[b.clientId];
      if (existing == null || b.date.compareTo(existing.date) > 0) {
        byClient[b.clientId] = b;
      }
    }
    return byClient.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  void onFilterChanged(String filter) {
    _filter = filter;
    _emit();
  }

  Future<void> respond(int bookingId, String status) async {
    try {
      await _repo.respond(bookingId, status);
      await load();
    } on BookingException catch (e) {
      DebugLogger.error(_tag, e.message);
    } catch (e) {
      DebugLogger.error(_tag, 'respond: $e');
    }
  }

  void _emit() {
    final filtered = _filter == 'all'
        ? _all
        : _all.where((b) => b.status == _filter).toList();
    if (!isClosed) emit(LawyerBookingsLoaded(bookings: filtered, filter: _filter));
  }
}

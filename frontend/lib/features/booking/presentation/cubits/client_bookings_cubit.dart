import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import 'client_bookings_state.dart';

class ClientBookingsCubit extends Cubit<ClientBookingsState> {
  static const _tag = 'ClientBookingsCubit';
  final BookingRepository _repo;
  List<BookingModel> _all = [];

  ClientBookingsCubit(this._repo) : super(ClientBookingsInitial());

  Future<void> load() async {
    if (isClosed) return;
    emit(ClientBookingsLoading());
    try {
      _all = await _repo.getMyBookings();
      if (!isClosed) emit(ClientBookingsLoaded(bookings: _all));
    } catch (e) {
      DebugLogger.error(_tag, 'load: $e');
      if (!isClosed) emit(ClientBookingsError(e.toString().replaceAll('BookingException: ', '')));
    }
  }

  Future<void> refresh() => load();

  void onFilterChanged(String filter) {
    if (isClosed) return;
    final filtered = filter == 'all'
        ? _all
        : _all.where((b) => b.status == filter).toList();
    if (!isClosed) emit(ClientBookingsLoaded(bookings: filtered, filter: filter));
  }
}

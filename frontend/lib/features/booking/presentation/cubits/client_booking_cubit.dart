import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/booking_repository.dart';
import '../../../lawyer/data/repositories/lawyer_repository.dart';
import 'client_booking_state.dart';

class ClientBookingCubit extends Cubit<ClientBookingState> {
  static const _tag = 'ClientBookingCubit';
  final BookingRepository _bookingRepo;
  final LawyerRepository _lawyerRepo;

  ClientBookingCubit(this._bookingRepo, this._lawyerRepo) : super(ClientBookingInitial());

  Future<void> loadAvailability(int lawyerId) async {
    if (isClosed) return;
    emit(ClientBookingLoading());
    try {
      final slotsMap = await _lawyerRepo.getAvailability(lawyerId);
      if (isClosed) return;
      if (slotsMap.isEmpty) {
        emit(ClientBookingNoSlots());
        return;
      }
      final dates = slotsMap.keys.toList()..sort();
      final firstSlots = slotsMap[dates.first] ?? [];
      emit(ClientBookingReady(
        slotsMap: slotsMap,
        availableDates: dates,
        selectedDate: dates.first,
        selectedSlot: firstSlots.isNotEmpty ? firstSlots.first : null,
      ));
    } catch (e) {
      DebugLogger.error(_tag, 'loadAvailability: $e');
      if (!isClosed) emit(ClientBookingError(e.toString().replaceAll('LawyerException: ', '')));
    }
  }

  void onDateSelected(String date) {
    if (isClosed) return;
    final s = state;
    if (s is! ClientBookingReady) return;
    final slots = s.slotsMap[date] ?? [];
    emit(ClientBookingReady(
      slotsMap: s.slotsMap,
      availableDates: s.availableDates,
      selectedDate: date,
      selectedSlot: slots.isNotEmpty ? slots.first : null,
      sessionType: s.sessionType,
      category: s.category,
    ));
  }

  void onSlotSelected(String slot) {
    if (isClosed) return;
    final s = state;
    if (s is! ClientBookingReady) return;
    emit(ClientBookingReady(
      slotsMap: s.slotsMap,
      availableDates: s.availableDates,
      selectedDate: s.selectedDate,
      selectedSlot: slot,
      sessionType: s.sessionType,
      category: s.category,
    ));
  }

  void onSessionTypeChanged(String type) {
    if (isClosed) return;
    final s = state;
    if (s is! ClientBookingReady) return;
    emit(ClientBookingReady(
      slotsMap: s.slotsMap,
      availableDates: s.availableDates,
      selectedDate: s.selectedDate,
      selectedSlot: s.selectedSlot,
      sessionType: type,
      category: s.category,
    ));
  }

  void onCategoryChanged(String cat) {
    if (isClosed) return;
    final s = state;
    if (s is! ClientBookingReady) return;
    emit(ClientBookingReady(
      slotsMap: s.slotsMap,
      availableDates: s.availableDates,
      selectedDate: s.selectedDate,
      selectedSlot: s.selectedSlot,
      sessionType: s.sessionType,
      category: cat,
    ));
  }

  Future<void> submit(int lawyerId, String caseBrief) async {
    if (isClosed) return;
    final s = state;
    if (s is! ClientBookingReady || !s.canSubmit) return;
    emit(ClientBookingSubmitting());
    try {
      final booking = await _bookingRepo.createBooking(
        lawyerId: lawyerId,
        date: s.selectedDate!,
        timeSlot: s.selectedSlot!,
        sessionType: s.sessionType,
        category: s.category,
        caseBrief: caseBrief,
      );
      if (!isClosed) emit(ClientBookingSuccess(booking));
    } catch (e) {
      DebugLogger.error(_tag, 'submit: $e');
      if (!isClosed) {
        emit(ClientBookingError(e.toString().replaceAll('BookingException: ', '')));
        emit(ClientBookingReady(
          slotsMap: s.slotsMap,
          availableDates: s.availableDates,
          selectedDate: s.selectedDate,
          selectedSlot: s.selectedSlot,
          sessionType: s.sessionType,
          category: s.category,
        ));
      }
    }
  }
}

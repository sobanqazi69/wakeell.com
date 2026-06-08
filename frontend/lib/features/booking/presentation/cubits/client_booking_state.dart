import 'package:equatable/equatable.dart';
import '../../data/models/booking_model.dart';

abstract class ClientBookingState extends Equatable {
  const ClientBookingState();
  @override
  List<Object?> get props => [];
}

class ClientBookingInitial extends ClientBookingState {}

class ClientBookingLoading extends ClientBookingState {}

class ClientBookingNoSlots extends ClientBookingState {}

class ClientBookingReady extends ClientBookingState {
  final Map<String, List<String>> slotsMap;
  final List<String> availableDates;
  final String? selectedDate;
  final String? selectedSlot;
  final String sessionType;
  final String category;

  const ClientBookingReady({
    required this.slotsMap,
    required this.availableDates,
    this.selectedDate,
    this.selectedSlot,
    this.sessionType = 'video',
    this.category = 'General',
  });

  List<String> get slotsForDate =>
      selectedDate != null ? (slotsMap[selectedDate!] ?? []) : [];

  bool get canSubmit => selectedDate != null && selectedSlot != null;

  @override
  List<Object?> get props => [slotsMap, availableDates, selectedDate, selectedSlot, sessionType, category];
}

class ClientBookingSubmitting extends ClientBookingState {}

class ClientBookingSuccess extends ClientBookingState {
  final BookingModel booking;
  const ClientBookingSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class ClientBookingError extends ClientBookingState {
  final String message;
  const ClientBookingError(this.message);
  @override
  List<Object?> get props => [message];
}

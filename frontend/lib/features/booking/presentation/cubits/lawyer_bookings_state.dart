import 'package:equatable/equatable.dart';
import '../../data/models/booking_model.dart';

abstract class LawyerBookingsState extends Equatable {
  const LawyerBookingsState();
  @override List<Object?> get props => [];
}

class LawyerBookingsInitial extends LawyerBookingsState { const LawyerBookingsInitial(); }
class LawyerBookingsLoading extends LawyerBookingsState { const LawyerBookingsLoading(); }

class LawyerBookingsLoaded extends LawyerBookingsState {
  final List<BookingModel> bookings;
  final String filter; // 'all', 'pending', 'confirmed', 'cancelled'
  const LawyerBookingsLoaded({required this.bookings, this.filter = 'all'});
  @override List<Object?> get props => [bookings, filter];
}

class LawyerBookingsError extends LawyerBookingsState {
  final String message;
  const LawyerBookingsError(this.message);
  @override List<Object?> get props => [message];
}

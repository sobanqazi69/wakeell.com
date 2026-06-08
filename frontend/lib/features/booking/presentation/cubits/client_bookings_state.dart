import 'package:equatable/equatable.dart';
import '../../data/models/booking_model.dart';

abstract class ClientBookingsState extends Equatable {
  const ClientBookingsState();
  @override
  List<Object?> get props => [];
}

class ClientBookingsInitial extends ClientBookingsState {}

class ClientBookingsLoading extends ClientBookingsState {}

class ClientBookingsLoaded extends ClientBookingsState {
  final List<BookingModel> bookings;
  final String filter;
  const ClientBookingsLoaded({required this.bookings, this.filter = 'all'});
  @override
  List<Object?> get props => [bookings, filter];
}

class ClientBookingsError extends ClientBookingsState {
  final String message;
  const ClientBookingsError(this.message);
  @override
  List<Object?> get props => [message];
}

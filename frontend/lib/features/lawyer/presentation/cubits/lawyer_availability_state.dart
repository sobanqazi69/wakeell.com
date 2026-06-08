import 'package:equatable/equatable.dart';

abstract class LawyerAvailabilityState extends Equatable {
  const LawyerAvailabilityState();
  @override List<Object?> get props => [];
}

class LawyerAvailabilityInitial extends LawyerAvailabilityState { const LawyerAvailabilityInitial(); }
class LawyerAvailabilityLoading extends LawyerAvailabilityState { const LawyerAvailabilityLoading(); }
class LawyerAvailabilitySaving  extends LawyerAvailabilityState { const LawyerAvailabilitySaving(); }
class LawyerAvailabilitySaved   extends LawyerAvailabilityState { const LawyerAvailabilitySaved(); }

/// Slots per day-of-week index: 0=Mon ... 6=Sun
class LawyerAvailabilityLoaded extends LawyerAvailabilityState {
  final Map<int, List<String>> schedule; // dayIndex → list of time strings e.g. '09:00'
  const LawyerAvailabilityLoaded(this.schedule);
  @override List<Object?> get props => [schedule];
}

class LawyerAvailabilityError extends LawyerAvailabilityState {
  final String message;
  const LawyerAvailabilityError(this.message);
  @override List<Object?> get props => [message];
}

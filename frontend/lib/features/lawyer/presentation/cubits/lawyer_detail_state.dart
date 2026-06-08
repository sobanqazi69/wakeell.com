import 'package:equatable/equatable.dart';
import '../../data/models/lawyer_model.dart';

abstract class LawyerDetailState extends Equatable {
  const LawyerDetailState();
  @override
  List<Object?> get props => [];
}

class LawyerDetailInitial extends LawyerDetailState { const LawyerDetailInitial(); }
class LawyerDetailLoading extends LawyerDetailState { const LawyerDetailLoading(); }

class LawyerDetailLoaded extends LawyerDetailState {
  final LawyerModel lawyer;
  const LawyerDetailLoaded(this.lawyer);
  @override
  List<Object?> get props => [lawyer];
}

class LawyerDetailError extends LawyerDetailState {
  final String message;
  const LawyerDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

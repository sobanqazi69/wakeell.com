import 'package:equatable/equatable.dart';
import '../../data/models/lawyer_model.dart';
import '../../data/models/review_model.dart';

abstract class LawyerDetailState extends Equatable {
  const LawyerDetailState();
  @override
  List<Object?> get props => [];
}

class LawyerDetailInitial extends LawyerDetailState { const LawyerDetailInitial(); }
class LawyerDetailLoading extends LawyerDetailState { const LawyerDetailLoading(); }

class LawyerDetailLoaded extends LawyerDetailState {
  final LawyerModel lawyer;
  final List<ReviewModel> reviews;
  const LawyerDetailLoaded(this.lawyer, [this.reviews = const []]);
  @override
  List<Object?> get props => [lawyer, reviews];
}

class LawyerDetailError extends LawyerDetailState {
  final String message;
  const LawyerDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

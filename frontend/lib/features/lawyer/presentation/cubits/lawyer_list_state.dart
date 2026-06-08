import 'package:equatable/equatable.dart';
import '../../data/models/lawyer_model.dart';

abstract class LawyerListState extends Equatable {
  const LawyerListState();
  @override
  List<Object?> get props => [];
}

class LawyerListInitial   extends LawyerListState { const LawyerListInitial(); }
class LawyerListLoading   extends LawyerListState { const LawyerListLoading(); }

class LawyerListLoaded extends LawyerListState {
  final List<LawyerModel> lawyers;
  final String search;
  final String category;

  const LawyerListLoaded({required this.lawyers, required this.search, required this.category});

  @override
  List<Object?> get props => [lawyers, search, category];
}

class LawyerListError extends LawyerListState {
  final String message;
  const LawyerListError(this.message);
  @override
  List<Object?> get props => [message];
}

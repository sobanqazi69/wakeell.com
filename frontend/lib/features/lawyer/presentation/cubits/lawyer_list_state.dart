import 'package:equatable/equatable.dart';
import '../../data/models/lawyer_model.dart';

abstract class LawyerListState extends Equatable {
  const LawyerListState();
  @override
  List<Object?> get props => [];
}

class LawyerListInitial   extends LawyerListState { const LawyerListInitial(); }
class LawyerListLoading   extends LawyerListState { const LawyerListLoading(); }
class LawyerListLocating  extends LawyerListState { const LawyerListLocating(); } // getting GPS

class LawyerListLoaded extends LawyerListState {
  final List<LawyerModel> lawyers;
  final String search;
  final String category;
  final String sort; // 'all' | 'top_rated' | 'low_fee' | 'near_me'

  const LawyerListLoaded({
    required this.lawyers,
    required this.search,
    required this.category,
    this.sort = 'all',
  });

  @override
  List<Object?> get props => [lawyers, search, category, sort];
}

class LawyerListError extends LawyerListState {
  final String message;
  const LawyerListError(this.message);
  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import '../../data/models/pending_lawyer_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final AdminStatsModel stats;
  final List<PendingLawyerModel> pendingLawyers;

  const AdminLoaded({required this.stats, required this.pendingLawyers});

  AdminLoaded copyWith({AdminStatsModel? stats, List<PendingLawyerModel>? pendingLawyers}) =>
      AdminLoaded(
        stats: stats ?? this.stats,
        pendingLawyers: pendingLawyers ?? this.pendingLawyers,
      );

  @override
  List<Object?> get props => [stats, pendingLawyers];
}

class AdminActionLoading extends AdminState {
  final int lawyerId;
  const AdminActionLoading(this.lawyerId);
  @override
  List<Object?> get props => [lawyerId];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

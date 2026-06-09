import 'package:equatable/equatable.dart';
import '../../data/models/lawyer_model.dart';

abstract class LawyerProfileState extends Equatable {
  const LawyerProfileState();
  @override
  List<Object?> get props => [];
}

class LawyerProfileInitial  extends LawyerProfileState { const LawyerProfileInitial(); }
class LawyerProfileLoading  extends LawyerProfileState { const LawyerProfileLoading(); }
class LawyerProfileSaving   extends LawyerProfileState {
  final LawyerModel lawyer;
  const LawyerProfileSaving(this.lawyer);
  @override List<Object?> get props => [lawyer];
}

class LawyerProfileLoaded extends LawyerProfileState {
  final LawyerModel lawyer;
  const LawyerProfileLoaded(this.lawyer);
  @override List<Object?> get props => [lawyer];
}

class LawyerProfileSaved extends LawyerProfileState {
  final LawyerModel lawyer;
  const LawyerProfileSaved(this.lawyer);
  @override List<Object?> get props => [lawyer];
}

class LawyerProfileError extends LawyerProfileState {
  final String message;
  const LawyerProfileError(this.message);
  @override List<Object?> get props => [message];
}

class LawyerProfileAvatarUpdating extends LawyerProfileState {
  final LawyerModel lawyer;
  const LawyerProfileAvatarUpdating(this.lawyer);
  @override List<Object?> get props => [lawyer];
}

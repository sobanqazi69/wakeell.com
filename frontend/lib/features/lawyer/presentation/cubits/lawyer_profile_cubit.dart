import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../../auth/data/repositories/auth_repository.dart'; // AuthException, AuthRepository
import '../../data/repositories/lawyer_repository.dart';
import 'lawyer_profile_state.dart';

class LawyerProfileCubit extends Cubit<LawyerProfileState> {
  static const _tag = 'LawyerProfileCubit';
  final LawyerRepository _lawyerRepo;
  final AuthRepository _authRepo;

  LawyerProfileCubit(this._lawyerRepo, this._authRepo) : super(const LawyerProfileInitial());

  Future<void> load() async {
    try {
      if (!isClosed) emit(const LawyerProfileLoading());
      final lawyer = await _lawyerRepo.getMyProfile();
      if (!isClosed) emit(LawyerProfileLoaded(lawyer));
    } on LawyerException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerProfileError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'load unexpected: $e');
      if (!isClosed) emit(const LawyerProfileError('Failed to load profile'));
    }
  }

  Future<void> save({
    required String name,
    required String phone,
    required String location,
    required String bio,
    required List<String> specializations,
    required List<String> languages,
    required double hourlyRate,
    required int experience,
  }) async {
    final current = state;
    if (current is! LawyerProfileLoaded) return;
    try {
      if (!isClosed) emit(LawyerProfileSaving(current.lawyer));

      await _authRepo.updateMe(name: name, phone: phone, location: location);
      await _lawyerRepo.updateMyProfile(
        bio: bio,
        specializations: specializations,
        languages: languages,
        hourlyRate: hourlyRate,
        experience: experience,
      );

      final refreshed = await _lawyerRepo.getMyProfile();
      if (!isClosed) emit(LawyerProfileSaved(refreshed));
    } on LawyerException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerProfileError(e.message));
    } on AuthException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerProfileError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'save unexpected: $e');
      if (!isClosed) emit(const LawyerProfileError('Failed to save profile'));
    }
  }
}

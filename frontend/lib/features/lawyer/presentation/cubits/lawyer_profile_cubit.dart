import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> uploadAvatar(XFile photo) async {
    final current = state;
    if (current is! LawyerProfileLoaded) return;
    try {
      if (!isClosed) emit(LawyerProfileAvatarUpdating(current.lawyer));
      final updatedUser = await _authRepo.uploadAvatar(photo);
      final refreshed = await _lawyerRepo.getMyProfile();
      if (!isClosed) emit(LawyerProfileLoaded(refreshed.copyWith(avatar: updatedUser.avatar)));
    } on AuthException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerProfileLoaded(current.lawyer));
      if (!isClosed) emit(LawyerProfileError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'uploadAvatar unexpected: $e');
      if (!isClosed) emit(LawyerProfileLoaded(current.lawyer));
      if (!isClosed) emit(const LawyerProfileError('Failed to upload photo'));
    }
  }

  Future<void> removeAvatar() async {
    final current = state;
    if (current is! LawyerProfileLoaded) return;
    try {
      if (!isClosed) emit(LawyerProfileAvatarUpdating(current.lawyer));
      await _authRepo.removeAvatar();
      final refreshed = await _lawyerRepo.getMyProfile();
      if (!isClosed) emit(LawyerProfileLoaded(refreshed.copyWith(avatar: null)));
    } on AuthException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerProfileLoaded(current.lawyer));
      if (!isClosed) emit(LawyerProfileError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'removeAvatar unexpected: $e');
      if (!isClosed) emit(LawyerProfileLoaded(current.lawyer));
      if (!isClosed) emit(const LawyerProfileError('Failed to remove photo'));
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

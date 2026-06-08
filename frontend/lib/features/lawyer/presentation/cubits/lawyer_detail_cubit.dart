import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/lawyer_repository.dart';
import 'lawyer_detail_state.dart';

class LawyerDetailCubit extends Cubit<LawyerDetailState> {
  static const _tag = 'LawyerDetailCubit';
  final LawyerRepository _repo;

  LawyerDetailCubit(this._repo) : super(const LawyerDetailInitial());

  Future<void> load(int lawyerId) async {
    try {
      if (!isClosed) emit(const LawyerDetailLoading());
      final lawyer = await _repo.getLawyerById(lawyerId);
      if (!isClosed) emit(LawyerDetailLoaded(lawyer));
    } on LawyerException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerDetailError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'unexpected: $e');
      if (!isClosed) emit(const LawyerDetailError('Failed to load profile'));
    }
  }
}

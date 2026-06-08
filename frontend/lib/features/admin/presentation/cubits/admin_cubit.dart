import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/models/pending_lawyer_model.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  static const _tag = 'AdminCubit';
  final AdminRepository _repo;

  AdminCubit(this._repo) : super(const AdminInitial());

  Future<void> loadDashboard() async {
    try {
      if (isClosed) return;
      emit(const AdminLoading());

      final results = await Future.wait([
        _repo.getStats(),
        _repo.getPendingLawyers(),
      ]);

      if (!isClosed) {
        emit(AdminLoaded(
          stats: results[0] as AdminStatsModel,
          pendingLawyers: results[1] as List<PendingLawyerModel>,
        ));
      }
    } on AdminException catch (e) {
      DebugLogger.error(_tag, 'loadDashboard: ${e.message}');
      if (!isClosed) emit(AdminError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'loadDashboard unexpected: $e');
      if (!isClosed) emit(const AdminError('Failed to load dashboard'));
    }
  }

  Future<void> approveLawyer(int lawyerId) async {
    await _verifyLawyer(lawyerId, 'approved');
  }

  Future<void> rejectLawyer(int lawyerId, {String? note}) async {
    await _verifyLawyer(lawyerId, 'rejected', adminNote: note);
  }

  Future<void> _verifyLawyer(int lawyerId, String status, {String? adminNote}) async {
    final current = state;
    if (current is! AdminLoaded) return;

    try {
      if (isClosed) return;
      emit(AdminActionLoading(lawyerId));

      await _repo.verifyLawyer(lawyerId: lawyerId, status: status, adminNote: adminNote);

      // Remove from pending list and refresh stats
      final updated = current.pendingLawyers.where((l) => l.id != lawyerId).toList();
      final newStats = AdminStatsModel(
        totalUsers:      current.stats.totalUsers,
        totalClients:    current.stats.totalClients,
        totalLawyers:    current.stats.totalLawyers,
        pendingLawyers:  current.stats.pendingLawyers - 1,
        approvedLawyers: status == 'approved'
            ? current.stats.approvedLawyers + 1
            : current.stats.approvedLawyers,
        rejectedLawyers: status == 'rejected'
            ? current.stats.rejectedLawyers + 1
            : current.stats.rejectedLawyers,
      );

      if (!isClosed) emit(AdminLoaded(stats: newStats, pendingLawyers: updated));
    } on AdminException catch (e) {
      DebugLogger.error(_tag, '_verifyLawyer: ${e.message}');
      if (!isClosed) emit(current); // restore previous state
    } catch (e) {
      DebugLogger.error(_tag, '_verifyLawyer unexpected: $e');
      if (!isClosed) emit(current);
    }
  }
}

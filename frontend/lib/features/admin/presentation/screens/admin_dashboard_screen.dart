import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import '../../data/models/pending_lawyer_model.dart';
import '../cubits/admin_cubit.dart';
import '../cubits/admin_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (_) => false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _AppBar(
                onLogout: () => context.read<AuthCubit>().logout(),
                onRefresh: () => context.read<AdminCubit>().loadDashboard(),
              ),
              Expanded(
                child: BlocBuilder<AdminCubit, AdminState>(
                  builder: (context, state) {
                    if (state is AdminLoading || state is AdminInitial) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2));
                    }
                    if (state is AdminError) {
                      return _ErrorView(message: state.message, onRetry: () => context.read<AdminCubit>().loadDashboard());
                    }

                    final loaded = state is AdminLoaded
                        ? state
                        : (state is AdminActionLoading
                            ? null
                            : null);

                    if (loaded == null) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2));
                    }

                    return RefreshIndicator(
                      color: AppColors.navy,
                      onRefresh: () => context.read<AdminCubit>().loadDashboard(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        children: [
                          _StatsGrid(stats: loaded.stats),
                          const SizedBox(height: 28),
                          _SectionHeader(
                            title: 'Pending Applications',
                            badge: loaded.stats.pendingLawyers,
                          ),
                          const SizedBox(height: 12),
                          if (loaded.pendingLawyers.isEmpty)
                            _EmptyPending()
                          else
                            ...loaded.pendingLawyers.map(
                              (l) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _LawyerCard(
                                  lawyer: l,
                                  isActioning: state is AdminActionLoading &&
                                      (state).lawyerId == l.id,
                                  onApprove: () => _confirm(
                                    context,
                                    action: 'approve',
                                    name: l.userName,
                                    onConfirm: () => context.read<AdminCubit>().approveLawyer(l.id),
                                  ),
                                  onReject: () => _showRejectSheet(context, l),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirm(BuildContext ctx, {required String action, required String name, required VoidCallback onConfirm}) {
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${action == 'approve' ? 'Approve' : 'Reject'} Lawyer?',
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text('Are you sure you want to $action $name?',
          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(dialogCtx); onConfirm(); },
            child: Text(
              action == 'approve' ? 'Approve' : 'Reject',
              style: GoogleFonts.outfit(
                color: action == 'approve' ? const Color(0xFF16A34A) : AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectSheet(BuildContext ctx, PendingLawyerModel lawyer) {
    final noteCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reject Application', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Provide a reason for ${lawyer.userName} (optional)',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'e.g. Incomplete documents, invalid bar license...'),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(sheetCtx),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.fieldBorder)),
                      child: Center(child: Text('Cancel', style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ctx.read<AdminCubit>().rejectLawyer(lawyer.id, note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim());
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text('Reject', style: GoogleFonts.outfit(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700))),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onRefresh;
  const _AppBar({required this.onLogout, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WAKEELL', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 2.5)),
          const SizedBox(height: 2),
          Text('Admin Panel', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: onRefresh,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.fieldBorder)),
            child: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onLogout,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.fieldBorder)),
            child: const Icon(Icons.logout_rounded, size: 17, color: AppColors.textSecondary),
          ),
        ),
      ]),
    );
  }
}

// ─── Stats grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final AdminStatsModel stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: _StatCard(label: 'Total Users', value: stats.totalUsers, icon: Icons.people_outline, color: AppColors.navy)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Clients', value: stats.totalClients, icon: Icons.person_outline, color: const Color(0xFF0D9488))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _StatCard(label: 'Pending', value: stats.pendingLawyers, icon: Icons.hourglass_top_rounded, color: const Color(0xFFD97706), highlight: stats.pendingLawyers > 0)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Approved', value: stats.approvedLawyers, icon: Icons.verified_outlined, color: const Color(0xFF16A34A))),
      ]),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: highlight ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5) : null,
        boxShadow: [AppColors.cardShadow(opacity: 0.06, blur: 16)],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$value', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int badge;
  const _SectionHeader({required this.title, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      if (badge > 0) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFD97706).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
          child: Text('$badge', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFD97706))),
        ),
      ],
    ]);
  }
}

// ─── Pending lawyer card ──────────────────────────────────────────────────────

class _LawyerCard extends StatelessWidget {
  final PendingLawyerModel lawyer;
  final bool isActioning;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _LawyerCard({required this.lawyer, required this.isActioning, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.cardShadow(opacity: 0.06, blur: 16)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Center(child: Text(lawyer.initials, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navy))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lawyer.userName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text(lawyer.userEmail, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFD97706).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('PENDING', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFD97706), letterSpacing: 0.5)),
          ),
        ]),
        const SizedBox(height: 14),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.badge_outlined, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(lawyer.barLicense, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text(lawyer.appliedDate, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textHint)),
        ]),
        const SizedBox(height: 16),
        isActioning
            ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2)))
            : Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onReject,
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                      ),
                      child: Center(child: Text('Reject', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onApprove,
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text('Approve', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                    ),
                  ),
                ),
              ]),
      ]),
    );
  }
}

// ─── Empty & error states ─────────────────────────────────────────────────────

class _EmptyPending extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        const Icon(Icons.check_circle_outline_rounded, size: 40, color: Color(0xFF16A34A)),
        const SizedBox(height: 12),
        Text('All caught up!', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text('No pending lawyer applications right now.', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 40, color: AppColors.textHint),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
            child: Text('Retry', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ]),
    ));
  }
}

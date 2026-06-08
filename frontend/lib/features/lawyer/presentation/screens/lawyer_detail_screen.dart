import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../data/models/lawyer_model.dart';
import '../cubits/lawyer_detail_cubit.dart';
import '../cubits/lawyer_detail_state.dart';

class LawyerDetailScreen extends StatefulWidget {
  const LawyerDetailScreen({super.key});

  @override
  State<LawyerDetailScreen> createState() => _LawyerDetailScreenState();
}

class _LawyerDetailScreenState extends State<LawyerDetailScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final id = ModalRoute.of(context)!.settings.arguments as int;
      context.read<LawyerDetailCubit>().load(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocBuilder<LawyerDetailCubit, LawyerDetailState>(
        builder: (context, state) {
          if (state is LawyerDetailLoading || state is LawyerDetailInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2));
          }
          if (state is LawyerDetailError) {
            return _ErrorBody(message: state.message, onBack: () => Navigator.pop(context));
          }
          if (state is LawyerDetailLoaded) return _Body(lawyer: state.lawyer);
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final LawyerModel lawyer;
  const _Body({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
      slivers: [
        // ── Hero header ──────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.navy,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.navy, AppColors.navyMid],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        // Avatar
                        Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                          ),
                          child: Center(
                            child: Text(lawyer.initials,
                              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(lawyer.name,
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                            if (lawyer.location != null) ...[
                              const SizedBox(height: 3),
                              Row(children: [
                                const Icon(Icons.location_on_outlined, size: 13, color: Colors.white70),
                                const SizedBox(width: 3),
                                Text(lawyer.location!, style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70)),
                              ]),
                            ],
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      // Stats row
                      Row(children: [
                        _StatBadge(icon: Icons.star_rounded, value: lawyer.ratingDisplay, label: 'Rating'),
                        const SizedBox(width: 12),
                        _StatBadge(icon: Icons.work_outline_rounded, value: '${lawyer.experience}y', label: 'Experience'),
                        const SizedBox(width: 12),
                        _StatBadge(icon: Icons.rate_review_outlined, value: '${lawyer.reviewCount}', label: 'Reviews'),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Rate card ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 14)],
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Consultation Fee', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(lawyer.formattedRate,
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy)),
                ])),
                if (lawyer.barLicense.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.verified_outlined, size: 14, color: Color(0xFF16A34A)),
                      const SizedBox(width: 5),
                      Text('Verified', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Bio ──────────────────────────────────────────────────────
            if (lawyer.bio.isNotEmpty) ...[
              _SectionTitle('About'),
              const SizedBox(height: 10),
              Text(lawyer.bio,
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
              const SizedBox(height: 20),
            ],

            // ── Specializations ──────────────────────────────────────────
            if (lawyer.specializations.isNotEmpty) ...[
              _SectionTitle('Practice Areas'),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                ...lawyer.specializations.map((s) => _DetailChip(label: s)),
              ]),
              const SizedBox(height: 20),
            ],

            // ── Languages ────────────────────────────────────────────────
            if (lawyer.languages.isNotEmpty) ...[
              _SectionTitle('Languages'),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                ...lawyer.languages.map((l) => _DetailChip(label: l, icon: Icons.language_outlined)),
              ]),
              const SizedBox(height: 20),
            ],

            // ── Details ──────────────────────────────────────────────────
            _SectionTitle('Details'),
            const SizedBox(height: 10),
            _InfoCard(children: [
              if (lawyer.jurisdiction != null)
                _InfoRow(icon: Icons.gavel_rounded, label: 'Jurisdiction', value: lawyer.jurisdiction!),
              if (lawyer.phone != null)
                _InfoRow(icon: Icons.phone_outlined, label: 'Contact', value: lawyer.phone!),
              _InfoRow(icon: Icons.badge_outlined, label: 'Bar License', value: lawyer.barLicense.isNotEmpty ? lawyer.barLicense : '—'),
            ]),
          ]),
        )),
      ],
        ),
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: _BookingCta(lawyer: lawyer),
        ),
      ],
    );
  }
}

// ─── CTA Bar ─────────────────────────────────────────────────────────────────

class _BookingCta extends StatelessWidget {
  final LawyerModel lawyer;
  const _BookingCta({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Consultation Fee', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
          Text(lawyer.formattedRate,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
        ]),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.booking,
              arguments: {'lawyerId': lawyer.id, 'lawyerName': lawyer.name},
            ),
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.navy, AppColors.navyMid]),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Center(child: Text('Book Consultation',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatBadge({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 5),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white60)),
        ]),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _DetailChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.12)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 13, color: AppColors.navy), const SizedBox(width: 5)],
        Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.navy)),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 14)],
      ),
      child: Column(children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: AppColors.divider),
            ),
        ],
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: AppColors.bg, shape: BoxShape.circle),
        child: Center(child: Icon(icon, size: 15, color: AppColors.navy)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ])),
    ]);
  }
}

// ─── Error body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  const _ErrorBody({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: onBack,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.fieldBorder)),
              child: const Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
      Expanded(child: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.person_off_outlined, size: 48, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
        ]),
      ))),
    ]));
  }
}

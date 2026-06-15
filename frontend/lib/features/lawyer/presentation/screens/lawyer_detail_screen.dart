import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/lawyer_model.dart';
import '../../data/models/review_model.dart';
import '../cubits/lawyer_detail_cubit.dart';
import '../cubits/lawyer_detail_state.dart';

String _imgUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return ApiClient.baseUrl.replaceAll('/api', '') + path;
}

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
            return Container(
              color: AppColors.darkBg,
              child: const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2)),
            );
          }
          if (state is LawyerDetailError) {
            return _ErrorBody(message: state.message, onBack: () => Navigator.pop(context));
          }
          if (state is LawyerDetailLoaded) {
            return _Body(lawyer: state.lawyer, reviews: state.reviews);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final LawyerModel lawyer;
  final List<ReviewModel> reviews;
  const _Body({required this.lawyer, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _imgUrl(lawyer.avatar);

    return Stack(children: [
      CustomScrollView(
        slivers: [
          // ── Expanded header ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.darkBg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.darkBg, AppColors.cardBg],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Avatar with cyan glow
                        Container(
                          width: 88, height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cyan, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: avatarUrl.isNotEmpty
                                ? Image.network(avatarUrl, fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => _InitialsAvatar(lawyer.initials))
                                : _InitialsAvatar(lawyer.initials),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Name
                        Text(lawyer.name,
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        if (lawyer.location != null) ...[
                          const SizedBox(height: 4),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.location_on_rounded, size: 12, color: AppColors.cyan),
                            const SizedBox(width: 3),
                            Text(lawyer.location!,
                              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.darkTextSub)),
                          ]),
                        ],
                        const SizedBox(height: 14),

                        // Stats bar — single glassy container
                        _StatsBar(lawyer: lawyer, reviewCount: reviews.length),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Fee card
                _FeeCard(lawyer: lawyer),
                const SizedBox(height: 16),

                // Bio
                if (lawyer.bio.isNotEmpty) ...[
                  _SectionHeader('About'),
                  const SizedBox(height: 10),
                  _BioCard(bio: lawyer.bio),
                  const SizedBox(height: 16),
                ],

                // Practice areas
                if (lawyer.specializations.isNotEmpty) ...[
                  _SectionHeader('Practice Areas'),
                  const SizedBox(height: 10),
                  _ChipWrap(items: lawyer.specializations, color: AppColors.navy),
                  const SizedBox(height: 16),
                ],

                // Languages
                if (lawyer.languages.isNotEmpty) ...[
                  _SectionHeader('Languages'),
                  const SizedBox(height: 10),
                  _ChipWrap(
                    items: lawyer.languages,
                    icon: Icons.language_outlined,
                    color: AppColors.navyMid,
                  ),
                  const SizedBox(height: 16),
                ],

                // Details
                _SectionHeader('Details'),
                const SizedBox(height: 10),
                _DetailsCard(lawyer: lawyer),
                const SizedBox(height: 20),

                // Reviews
                _SectionHeader('Client Reviews', count: reviews.length),
                const SizedBox(height: 12),
                if (reviews.isEmpty)
                  _EmptyReviews()
                else
                  ...reviews.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReviewCard(review: r),
                  )),
              ]),
            ),
          ),
        ],
      ),

      // Booking CTA
      Positioned(
        left: 0, right: 0, bottom: 0,
        child: _BookingCta(lawyer: lawyer),
      ),
    ]);
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  const _InitialsAvatar(this.initials);
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.cardBgAlt,
    child: Center(child: Text(initials,
      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white))),
  );
}

class _StatsBar extends StatelessWidget {
  final LawyerModel lawyer;
  final int reviewCount;
  const _StatsBar({required this.lawyer, required this.reviewCount});

  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    child: Row(children: [
      Expanded(child: _StatCell(
        value: lawyer.ratingDisplay,
        label: 'Rating',
        icon: Icons.star_rounded,
        iconColor: AppColors.gold,
      )),
      _VertDivider(),
      Expanded(child: _StatCell(
        value: '${lawyer.experience}y',
        label: 'Experience',
      )),
      _VertDivider(),
      Expanded(child: _StatCell(
        value: '$reviewCount',
        label: 'Reviews',
        icon: Icons.chat_bubble_outline_rounded,
        iconColor: AppColors.cyan,
      )),
    ]),
  );
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color iconColor;
  const _StatCell({required this.value, required this.label, this.icon, this.iconColor = Colors.white70});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 3),
        ],
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
      ]),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54, letterSpacing: 0.2)),
    ],
  );
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 32,
    color: Colors.white.withValues(alpha: 0.12),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  const _SectionHeader(this.title, {this.count});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 18,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.cyan, AppColors.navy],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
    const SizedBox(width: 8),
    Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    if (count != null) ...[
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.navy.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$count', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
      ),
    ],
  ]);
}

class _FeeCard extends StatelessWidget {
  final LawyerModel lawyer;
  const _FeeCard({required this.lawyer});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [AppColors.cardShadow(opacity: 0.06, blur: 16)],
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Consultation Fee',
          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(lawyer.formattedRate,
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.navy)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.verified_rounded, size: 15, color: AppColors.success),
          const SizedBox(width: 5),
          Text('Bar Verified', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
        ]),
      ),
    ]),
  );
}

class _BioCard extends StatelessWidget {
  final String bio;
  const _BioCard({required this.bio});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 12)],
    ),
    child: Text(bio,
      style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
  );
}

class _ChipWrap extends StatelessWidget {
  final List<String> items;
  final Color color;
  final IconData? icon;
  const _ChipWrap({required this.items, required this.color, this.icon});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: items.map((s) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 5)],
        Text(s, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ]),
    )).toList(),
  );
}

class _DetailsCard extends StatelessWidget {
  final LawyerModel lawyer;
  const _DetailsCard({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[];
    if (lawyer.jurisdiction != null) {
      rows.add(_InfoRow(icon: Icons.gavel_rounded, label: 'Jurisdiction', value: lawyer.jurisdiction!));
    }
    if (lawyer.phone != null) {
      rows.add(_InfoRow(icon: Icons.phone_outlined, label: 'Contact', value: lawyer.phone!));
    }
    if (lawyer.barLicense.isNotEmpty) {
      rows.add(_InfoRow(icon: Icons.badge_outlined, label: 'Bar License', value: lawyer.barLicense));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 12)],
      ),
      child: Column(children: [
        for (int i = 0; i < rows.length; i++) ...[
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: rows[i]),
          if (i < rows.length - 1)
            const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
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
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 16, color: AppColors.navy),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint)),
      Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    ])),
  ]);
}

class _EmptyReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 10)],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.rate_review_outlined, size: 36, color: AppColors.textHint),
      const SizedBox(height: 10),
      Text('No reviews yet', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      Text('Be the first to leave a review after your consultation',
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textHint, height: 1.5)),
    ]),
  );
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _imgUrl(review.clientAvatar);
    final dateStr = DateFormat('MMM d, yyyy').format(review.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 12)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Client avatar
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.fieldBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl.isNotEmpty
                ? Image.network(avatarUrl, fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => _ClientInitials(review.initials))
                : _ClientInitials(review.initials),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(review.clientName,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text(dateStr, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint)),
          ])),
          // Stars
          Row(children: List.generate(5, (i) => Icon(
            i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 16,
            color: i < review.rating ? AppColors.gold : AppColors.fieldBorder,
          ))),
        ]),
        if (review.comment.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          Text(review.comment,
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
        ],
      ]),
    );
  }
}

class _ClientInitials extends StatelessWidget {
  final String initials;
  const _ClientInitials(this.initials);
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.navy.withValues(alpha: 0.08),
    child: Center(child: Text(initials,
      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy))),
  );
}

// ─── Booking CTA ─────────────────────────────────────────────────────────────

class _BookingCta extends StatelessWidget {
  final LawyerModel lawyer;
  const _BookingCta({required this.lawyer});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: const Border(top: BorderSide(color: AppColors.divider)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
    ),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('Consultation Fee', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint)),
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
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.navy, AppColors.navyMid]),
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Book Consultation',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ])),
          ),
        ),
      ),
    ]),
  );
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  const _ErrorBody({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) => SafeArea(child: Column(children: [
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

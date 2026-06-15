import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../data/models/lawyer_model.dart';
import '../cubits/lawyer_list_cubit.dart';
import '../cubits/lawyer_list_state.dart';

const _kCategories = [
  'All', 'Corporate', 'Criminal', 'Family', 'Property',
  'Immigration', 'Tax', 'Labour', 'Civil', 'Intellectual Property',
];

String _resolveAvatar(String? relative) {
  if (relative == null || relative.isEmpty) return '';
  if (relative.startsWith('http')) return relative;
  return '${ApiClient.baseUrl.replaceAll('/api', '')}$relative';
}

class LawyersListScreen extends StatefulWidget {
  const LawyersListScreen({super.key});

  @override
  State<LawyersListScreen> createState() => _LawyersListScreenState();
}

class _LawyersListScreenState extends State<LawyersListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LawyerListCubit>().load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _handleNearMe() {
    final city = context.read<AuthCubit>().currentUser?.location ?? '';
    if (city.isEmpty) {
      AppSnackbar.info(context, 'Set your city in your profile to use this filter');
      return;
    }
    context.read<LawyerListCubit>().onNearMeFilter(city);
  }

  void _showFilterSheet(LawyerListLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        cubit: context.read<LawyerListCubit>(),
        initialMinRating: state.minRating,
        initialMaxFee: state.maxFee,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.fieldBorder)),
                    child: const Icon(Icons.arrow_back,
                        size: 18, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Find a Lawyer',
                            style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        BlocBuilder<LawyerListCubit, LawyerListState>(
                          builder: (context, state) {
                            final count = state is LawyerListLoaded
                                ? state.lawyers.length
                                : null;
                            return Text(
                              count != null
                                  ? '$count verified professionals'
                                  : 'Browse verified professionals',
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            );
                          },
                        ),
                      ]),
                ),
                // Filter button
                BlocBuilder<LawyerListCubit, LawyerListState>(
                  builder: (context, state) {
                    final hasFilter = state is LawyerListLoaded &&
                        (state.minRating > 0 || state.maxFee > 0);
                    return GestureDetector(
                      onTap: state is LawyerListLoaded
                          ? () => _showFilterSheet(state)
                          : null,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: hasFilter
                              ? AppColors.navy
                              : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: hasFilter
                                  ? AppColors.navy
                                  : AppColors.fieldBorder),
                        ),
                        child: Icon(Icons.tune_rounded,
                            size: 18,
                            color: hasFilter
                                ? Colors.white
                                : AppColors.textPrimary),
                      ),
                    );
                  },
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Search bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.fieldBorder),
                  boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 12)],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      context.read<LawyerListCubit>().onSearchChanged(v),
                  style: GoogleFonts.outfit(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name…',
                    hintStyle: GoogleFonts.outfit(
                        color: AppColors.textHint, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 20, color: AppColors.textSecondary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              context
                                  .read<LawyerListCubit>()
                                  .onSearchChanged('');
                            },
                            child: const Icon(Icons.cancel_outlined,
                                size: 18, color: AppColors.textSecondary),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Category chips ────────────────────────────────────────────
            BlocBuilder<LawyerListCubit, LawyerListState>(
              builder: (context, state) {
                final selected =
                    state is LawyerListLoaded ? state.category : 'All';
                return SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: _kCategories.length,
                    separatorBuilder: (_, i) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _kCategories[i];
                      final isSelected = cat == selected;
                      return GestureDetector(
                        onTap: () => context
                            .read<LawyerListCubit>()
                            .onCategoryChanged(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.navy
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.navy
                                    : AppColors.fieldBorder),
                          ),
                          child: Center(
                            child: Text(cat,
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary)),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // ── Sort filters ──────────────────────────────────────────────
            BlocBuilder<LawyerListCubit, LawyerListState>(
              builder: (context, state) {
                final activeSort =
                    state is LawyerListLoaded ? state.sort : 'all';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    _SortChip(
                        label: '⭐ Top Rated',
                        value: 'top_rated',
                        activeSort: activeSort,
                        onTap: () => context
                            .read<LawyerListCubit>()
                            .onSortChanged('top_rated')),
                    const SizedBox(width: 8),
                    _SortChip(
                        label: '💰 Low Fee',
                        value: 'low_fee',
                        activeSort: activeSort,
                        onTap: () => context
                            .read<LawyerListCubit>()
                            .onSortChanged('low_fee')),
                    const SizedBox(width: 8),
                    _SortChip(
                      label: '📍 Near Me',
                      value: 'near_me',
                      activeSort: activeSort,
                      onTap: () {
                        if (activeSort == 'near_me') {
                          context.read<LawyerListCubit>().onSortChanged('all');
                        } else {
                          _handleNearMe();
                        }
                      },
                    ),
                  ]),
                );
              },
            ),
            const SizedBox(height: 12),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<LawyerListCubit, LawyerListState>(
                builder: (context, state) {
                  if (state is LawyerListLoading ||
                      state is LawyerListInitial) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.navy, strokeWidth: 2));
                  }
                  if (state is LawyerListError) {
                    return _ErrorView(
                        message: state.message,
                        onRetry: () =>
                            context.read<LawyerListCubit>().refresh());
                  }
                  if (state is LawyerListLoaded) {
                    if (state.lawyers.isEmpty) {
                      return _EmptyView(search: state.search);
                    }
                    return RefreshIndicator(
                      color: AppColors.navy,
                      onRefresh: () =>
                          context.read<LawyerListCubit>().refresh(),
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: state.lawyers.length,
                        separatorBuilder: (_, i) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) => _LawyerCard(
                          lawyer: state.lawyers[i],
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.lawyerDetail,
                            arguments: state.lawyers[i].id,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter bottom sheet ──────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final LawyerListCubit cubit;
  final double initialMinRating;
  final double initialMaxFee;
  const _FilterSheet(
      {required this.cubit,
      required this.initialMinRating,
      required this.initialMaxFee});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const _ratingOptions = [0.0, 3.0, 3.5, 4.0, 4.5];
  static const _ratingLabels = ['Any', '3.0+', '3.5+', '4.0+', '4.5+'];

  late double _minRating;
  late double _maxFee;

  @override
  void initState() {
    super.initState();
    _minRating = widget.initialMinRating;
    _maxFee = widget.initialMaxFee == 0 ? 50000 : widget.initialMaxFee;
  }

  void _apply() {
    widget.cubit.applyFilters(
      minRating: _minRating,
      maxFee: _maxFee >= 50000 ? 0 : _maxFee,
    );
    Navigator.pop(context);
  }

  void _reset() {
    widget.cubit.applyFilters(minRating: 0, maxFee: 0);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: AppColors.fieldBorder,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 20),

        // Title row
        Row(children: [
          Text('Filter Lawyers',
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Spacer(),
          GestureDetector(
            onTap: _reset,
            child: Text('Reset',
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error)),
          ),
        ]),
        const SizedBox(height: 24),

        // Minimum rating
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Minimum Rating',
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_ratingOptions.length, (i) {
            final isSelected = _minRating == _ratingOptions[i];
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _minRating = _ratingOptions[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.navy
                        : AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isSelected
                            ? AppColors.navy
                            : AppColors.fieldBorder),
                  ),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (i > 0)
                          Icon(Icons.star_rounded,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFD97706)),
                        const SizedBox(height: 2),
                        Text(_ratingLabels[i],
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary)),
                      ]),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Max fee
        Row(children: [
          Text('Max Consultation Fee',
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Spacer(),
          Text(
            _maxFee >= 50000
                ? 'Any'
                : 'PKR ${_maxFee.toInt()}',
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.navy),
          ),
        ]),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.navy,
            inactiveTrackColor: AppColors.fieldBorder,
            thumbColor: AppColors.navy,
            overlayColor: AppColors.navy.withValues(alpha: 0.12),
            trackHeight: 4,
          ),
          child: Slider(
            value: _maxFee,
            min: 500,
            max: 50000,
            divisions: 99,
            onChanged: (v) => setState(() => _maxFee = v),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PKR 500',
                style: GoogleFonts.outfit(
                    fontSize: 11, color: AppColors.textHint)),
            Text('Any',
                style: GoogleFonts.outfit(
                    fontSize: 11, color: AppColors.textHint)),
          ],
        ),
        const SizedBox(height: 28),

        // Apply button
        GestureDetector(
          onTap: _apply,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text('Apply Filters',
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Lawyer card ──────────────────────────────────────────────────────────────

class _LawyerCard extends StatelessWidget {
  final LawyerModel lawyer;
  final VoidCallback onTap;
  const _LawyerCard({required this.lawyer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _resolveAvatar(lawyer.avatar);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow(opacity: 0.06, blur: 16)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarUrl.isNotEmpty
                    ? Image.network(avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                            child: Text(lawyer.initials,
                                style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy))))
                    : Center(
                        child: Text(lawyer.initials,
                            style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy))),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lawyer.name,
                          style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      if (lawyer.location != null) ...[
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(lawyer.location!,
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ]),
                      ],
                      if (lawyer.experience > 0) ...[
                        const SizedBox(height: 2),
                        Text('${lawyer.experience} yrs experience',
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColors.textHint)),
                      ],
                    ]),
              ),

              // Rating badge
              if (lawyer.rating > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFFB45309)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(lawyer.ratingDisplay,
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ]),
                        if (lawyer.reviewCount > 0)
                          Text('${lawyer.reviewCount} reviews',
                              style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  color: Colors.white70)),
                      ]),
                ),
            ]),

            // Stars row
            if (lawyer.rating > 0) ...[
              const SizedBox(height: 10),
              _StarRow(rating: lawyer.rating),
            ],
            const SizedBox(height: 10),

            // Specialization chips
            if (lawyer.specializations.isNotEmpty)
              Wrap(spacing: 6, runSpacing: 6, children: [
                ...lawyer.specializations.take(3).map((s) => _Chip(label: s)),
                if (lawyer.specializations.length > 3)
                  _Chip(
                      label: '+${lawyer.specializations.length - 3}',
                      muted: true),
              ]),
            const SizedBox(height: 12),

            // Rate + CTA row
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(lawyer.formattedRate,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
              ),
              const Spacer(),
              Row(children: [
                Text('View Profile',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.navyMid,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 11, color: AppColors.navyMid),
              ]),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: 14,
          color: filled || half
              ? const Color(0xFFD97706)
              : AppColors.fieldBorder,
        );
      }),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool muted;
  const _Chip({required this.label, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: muted
            ? AppColors.bg
            : AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: muted
                ? AppColors.fieldBorder
                : AppColors.navy.withValues(alpha: 0.12)),
      ),
      child: Text(label,
          style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: muted ? AppColors.textHint : AppColors.navy)),
    );
  }
}

// ─── Empty & error ────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String search;
  const _EmptyView({required this.search});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_off_rounded,
            size: 48, color: AppColors.textHint),
        const SizedBox(height: 16),
        Text(
            search.isEmpty
                ? 'No lawyers found'
                : 'No results for "$search"',
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text('Try a different name, category or adjust filters',
            style:
                GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    ));
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String activeSort;
  final VoidCallback? onTap;
  const _SortChip(
      {required this.label,
      required this.value,
      required this.activeSort,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOn = value == activeSort;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOn ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isOn ? AppColors.navy : AppColors.fieldBorder),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOn ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded,
            size: 44, color: AppColors.textHint),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
                fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(8)),
            child: Text('Retry',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
      ]),
    ));
  }
}

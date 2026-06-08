import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/models/lawyer_model.dart';
import '../cubits/lawyer_list_cubit.dart';
import '../cubits/lawyer_list_state.dart';

const _kCategories = [
  'All', 'Corporate', 'Criminal', 'Family', 'Property',
  'Immigration', 'Tax', 'Labour', 'Civil', 'Intellectual Property',
];

class LawyersListScreen extends StatefulWidget {
  const LawyersListScreen({super.key});

  @override
  State<LawyersListScreen> createState() => _LawyersListScreenState();
}

class _LawyersListScreenState extends State<LawyersListScreen> {
  static const _tag = 'LawyersListScreen';
  final _searchCtrl = TextEditingController();
  bool _locating = false;

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

  Future<void> _handleNearMe() async {
    try {
      setState(() => _locating = true);

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _locating = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Location permission denied. Enable in settings.', style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 10)));
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final city = placemarks.firstOrNull?.locality ?? placemarks.firstOrNull?.subAdministrativeArea ?? '';

      if (!mounted) return;
      setState(() => _locating = false);

      if (city.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not determine your city', style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
        ));
        return;
      }

      context.read<LawyerListCubit>().onNearMeFilter(city);
    } catch (e) {
      DebugLogger.error(_tag, 'nearMe: $e');
      if (mounted) {
        setState(() => _locating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not get your location', style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
        ));
      }
    }
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
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.fieldBorder)),
                    child: const Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Find a Lawyer', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  BlocBuilder<LawyerListCubit, LawyerListState>(
                    builder: (context, state) {
                      final count = state is LawyerListLoaded ? state.lawyers.length : null;
                      return Text(
                        count != null ? '$count verified professionals' : 'Browse verified professionals',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                      );
                    },
                  ),
                ]),
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
                  onChanged: (v) => context.read<LawyerListCubit>().onSearchChanged(v),
                  style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name…',
                    hintStyle: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              context.read<LawyerListCubit>().onSearchChanged('');
                            },
                            child: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.textSecondary),
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
                final selected = state is LawyerListLoaded ? state.category : 'All';
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
                        onTap: () => context.read<LawyerListCubit>().onCategoryChanged(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.navy : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppColors.navy : AppColors.fieldBorder),
                          ),
                          child: Center(
                            child: Text(cat,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              )),
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
                final activeSort = state is LawyerListLoaded ? state.sort : 'all';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    _SortChip(label: '⭐ Top Rated', value: 'top_rated', activeSort: activeSort, onTap: () => context.read<LawyerListCubit>().onSortChanged('top_rated')),
                    const SizedBox(width: 8),
                    _SortChip(label: '💰 Low Fee', value: 'low_fee', activeSort: activeSort, onTap: () => context.read<LawyerListCubit>().onSortChanged('low_fee')),
                    const SizedBox(width: 8),
                    _SortChip(
                      label: _locating ? '…' : '📍 Near Me',
                      value: 'near_me',
                      activeSort: activeSort,
                      onTap: _locating ? null : () {
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
                  if (state is LawyerListLoading || state is LawyerListInitial) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2));
                  }
                  if (state is LawyerListError) {
                    return _ErrorView(message: state.message, onRetry: () => context.read<LawyerListCubit>().refresh());
                  }
                  if (state is LawyerListLoaded) {
                    if (state.lawyers.isEmpty) return _EmptyView(search: state.search);
                    return RefreshIndicator(
                      color: AppColors.navy,
                      onRefresh: () => context.read<LawyerListCubit>().refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: state.lawyers.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 12),
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

// ─── Lawyer card ──────────────────────────────────────────────────────────────

class _LawyerCard extends StatelessWidget {
  final LawyerModel lawyer;
  final VoidCallback onTap;
  const _LawyerCard({required this.lawyer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow(opacity: 0.06, blur: 16)],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(lawyer.initials,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy)),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(lawyer.name,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ),
                // Rating
                if (lawyer.rating > 0)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 3),
                    Text(lawyer.ratingDisplay,
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ]),
              ]),
              const SizedBox(height: 4),

              // Location
              if (lawyer.location != null)
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(lawyer.location!, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              const SizedBox(height: 8),

              // Specialization chips
              if (lawyer.specializations.isNotEmpty)
                Wrap(spacing: 6, runSpacing: 6, children: [
                  ...lawyer.specializations.take(3).map((s) => _Chip(label: s)),
                  if (lawyer.specializations.length > 3)
                    _Chip(label: '+${lawyer.specializations.length - 3}', muted: true),
                ]),
              const SizedBox(height: 10),

              // Rate row
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(lawyer.formattedRate,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
                ),
                const Spacer(),
                Text('View Profile',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.navyMid, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.navyMid),
              ]),
            ]),
          ),
        ]),
      ),
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
        color: muted ? AppColors.bg : AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: muted ? AppColors.fieldBorder : AppColors.navy.withValues(alpha: 0.12)),
      ),
      child: Text(label,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500,
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
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
        const SizedBox(height: 16),
        Text(search.isEmpty ? 'No lawyers found' : 'No results for "$search"',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text('Try a different name or category',
          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    ));
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String activeSort;
  final VoidCallback? onTap;
  const _SortChip({required this.label, required this.value, required this.activeSort, this.onTap});

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
          border: Border.all(color: isOn ? AppColors.navy : AppColors.fieldBorder),
        ),
        child: Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: isOn ? Colors.white : AppColors.textSecondary)),
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
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.textHint),
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

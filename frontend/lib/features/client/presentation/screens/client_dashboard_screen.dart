import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import '../../../lawyer/data/models/lawyer_model.dart';
import '../../../lawyer/data/repositories/lawyer_repository.dart';
import '../../../lawyer/presentation/cubits/lawyer_list_cubit.dart';
import '../../../lawyer/presentation/cubits/lawyer_list_state.dart';

const _kCategories = [
  'All', 'Corporate', 'Criminal', 'Family', 'Property',
  'Immigration', 'Tax', 'Labour', 'Civil',
];

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LawyerListCubit(getIt<LawyerRepository>())..load(),
      child: const _ClientDashboardBody(),
    );
  }
}

class _ClientDashboardBody extends StatefulWidget {
  const _ClientDashboardBody();
  @override
  State<_ClientDashboardBody> createState() => _ClientDashboardBodyState();
}

class _ClientDashboardBodyState extends State<_ClientDashboardBody> {
  static const _tag = 'ClientDashboard';
  final _searchCtrl = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _locating = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleNearMe() async {
    try {
      setState(() => _locating = true);
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 10)),
      );
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final city = placemarks.firstOrNull?.locality ?? placemarks.firstOrNull?.subAdministrativeArea ?? '';
      if (!mounted) return;
      setState(() => _locating = false);
      if (city.isNotEmpty) context.read<LawyerListCubit>().onNearMeFilter(city);
    } catch (e) {
      DebugLogger.error(_tag, 'nearMe: $e');
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text('Are you sure you want to log out?', style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Log Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && mounted) await context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (_) => false);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final user = context.read<AuthCubit>().currentUser;

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.bg,
            drawer: _ClientDrawer(user: user, onLogout: _confirmLogout),
            body: SafeArea(
              child: Column(children: [
                // ── Top bar ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.fieldBorder),
                        ),
                        child: const Icon(Icons.menu_rounded, size: 20, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Find Legal Help', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                      Text(user?.name.split(' ').first ?? 'Welcome',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ])),
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.fieldBorder),
                      ),
                      child: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.textSecondary),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),

                // ── Search bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.fieldBorder),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) {
                        setState(() {});
                        context.read<LawyerListCubit>().onSearchChanged(v);
                      },
                      style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search by name or specialization…',
                        hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textHint),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () { _searchCtrl.clear(); context.read<LawyerListCubit>().onSearchChanged(''); setState(() {}); },
                                child: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.textSecondary))
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Category chips ──────────────────────────────────────
                BlocBuilder<LawyerListCubit, LawyerListState>(
                  builder: (context, state) {
                    final cat = state is LawyerListLoaded ? state.category : 'All';
                    return SizedBox(
                      height: 32,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: _kCategories.length,
                        separatorBuilder: (_, i) => const SizedBox(width: 7),
                        itemBuilder: (_, i) {
                          final c = _kCategories[i];
                          final on = c == cat;
                          return GestureDetector(
                            onTap: () => context.read<LawyerListCubit>().onCategoryChanged(c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: on ? AppColors.navy : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: on ? AppColors.navy : AppColors.fieldBorder),
                              ),
                              child: Center(child: Text(c, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.textSecondary))),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // ── Sort filters ────────────────────────────────────────
                BlocBuilder<LawyerListCubit, LawyerListState>(
                  builder: (context, state) {
                    final sort = state is LawyerListLoaded ? state.sort : 'all';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(children: [
                        _SortChip(
                          icon: Icons.star_rounded,
                          label: 'Top Rated',
                          value: 'top_rated',
                          activeSort: sort,
                          onTap: () => context.read<LawyerListCubit>().onSortChanged(sort == 'top_rated' ? 'all' : 'top_rated'),
                        ),
                        const SizedBox(width: 8),
                        _SortChip(
                          icon: Icons.payments_outlined,
                          label: 'Low Fee',
                          value: 'low_fee',
                          activeSort: sort,
                          onTap: () => context.read<LawyerListCubit>().onSortChanged(sort == 'low_fee' ? 'all' : 'low_fee'),
                        ),
                        const SizedBox(width: 8),
                        _SortChip(
                          icon: _locating ? Icons.hourglass_top_rounded : Icons.near_me_outlined,
                          label: _locating ? 'Locating…' : 'Near Me',
                          value: 'near_me',
                          activeSort: sort,
                          onTap: _locating
                              ? null
                              : () => sort == 'near_me'
                                  ? context.read<LawyerListCubit>().onSortChanged('all')
                                  : _handleNearMe(),
                        ),
                      ]),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // ── Lawyers count header ────────────────────────────────
                BlocBuilder<LawyerListCubit, LawyerListState>(
                  builder: (context, state) {
                    if (state is! LawyerListLoaded) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(children: [
                        Text(
                          '${state.lawyers.length} lawyer${state.lawyers.length == 1 ? '' : 's'} found',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ]),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // ── Lawyer list ─────────────────────────────────────────
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
                        if (state.lawyers.isEmpty) {
                          return _EmptyView(search: state.search, sort: state.sort);
                        }
                        return RefreshIndicator(
                          color: AppColors.navy,
                          onRefresh: () => context.read<LawyerListCubit>().refresh(),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: state.lawyers.length,
                            separatorBuilder: (_, i) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => _LawyerCard(
                              lawyer: state.lawyers[i],
                              onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerDetail, arguments: state.lawyers[i].id),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ─── Drawer ───────────────────────────────────────────────────────────────────

class _ClientDrawer extends StatelessWidget {
  final dynamic user;
  final VoidCallback onLogout;
  const _ClientDrawer({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 28),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.navy, Color(0xFF2C3063)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
              ),
              child: Center(child: Text(
                _initials(user?.name ?? ''),
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              )),
            ),
            const SizedBox(height: 12),
            Text(user?.name ?? '', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            Text(user?.email ?? '', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
            if (user?.location != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 13, color: Colors.white54),
                const SizedBox(width: 4),
                Text(user!.location!, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
              ]),
            ],
          ]),
        ),

        const SizedBox(height: 8),
        _DrawerTile(
          icon: Icons.calendar_month_outlined,
          label: 'My Bookings',
          onTap: () { Navigator.pop(context); Navigator.pushNamed(context, AppRoutes.clientBookings); },
        ),
        _DrawerTile(icon: Icons.person_outline_rounded, label: 'My Profile', onTap: () { Navigator.pop(context); }),
        _DrawerTile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () { Navigator.pop(context); }),
        _DrawerTile(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () { Navigator.pop(context); }),
        _DrawerTile(icon: Icons.info_outline_rounded, label: 'About Wakeell', onTap: () { Navigator.pop(context); }),

        const Spacer(),
        const Divider(indent: 20, endIndent: 20, color: AppColors.fieldBorder),
        _DrawerTile(
          icon: Icons.logout_rounded,
          label: 'Log Out',
          color: AppColors.error,
          onTap: () { Navigator.pop(context); onLogout(); },
        ),
        const SizedBox(height: 16),
      ]),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DrawerTile({required this.icon, required this.label, this.color = AppColors.textPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: color),
      title: Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      minLeadingWidth: 20,
    );
  }
}

// ─── Lawyer card (premium) ────────────────────────────────────────────────────

class _LawyerCard extends StatelessWidget {
  final LawyerModel lawyer;
  final VoidCallback onTap;
  const _LawyerCard({required this.lawyer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 16)],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Avatar
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy, AppColors.navyMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(lawyer.initials,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Name + verified
                  Row(children: [
                    Expanded(child: Text(lawyer.name,
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis)),
                    if (lawyer.barLicense.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.verified_rounded, size: 11, color: AppColors.success),
                          const SizedBox(width: 3),
                          Text('Verified', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success)),
                        ]),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 4),

                  // Location + experience
                  Row(children: [
                    if (lawyer.location != null) ...[
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(lawyer.location!, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                    if (lawyer.location != null && lawyer.experience > 0) ...[
                      const SizedBox(width: 6),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.textHint, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                    ],
                    if (lawyer.experience > 0)
                      Text('${lawyer.experience} yrs exp',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                  ]),

                  // Specializations
                  if (lawyer.specializations.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(spacing: 5, runSpacing: 4, children: [
                      ...lawyer.specializations.take(2).map((s) => _SpecChip(s)),
                      if (lawyer.specializations.length > 2)
                        _SpecChip('+${lawyer.specializations.length - 2}', muted: true),
                    ]),
                  ],
                ]),
              ),
            ]),
          ),

          // Footer
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              if (lawyer.rating > 0) ...[
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                const SizedBox(width: 3),
                Text(lawyer.ratingDisplay,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(width: 4),
                Text('(${lawyer.reviewCount})',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
              ] else
                Text('No reviews yet',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textHint)),
              const Spacer(),
              Text(lawyer.formattedRate,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.textHint),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final String label;
  final bool muted;
  const _SpecChip(this.label, {this.muted = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: muted ? AppColors.bg : AppColors.navy.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500,
      color: muted ? AppColors.textHint : AppColors.navy)),
  );
}

// ─── Sort chip ────────────────────────────────────────────────────────────────

class _SortChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String activeSort;
  final VoidCallback? onTap;
  const _SortChip({required this.icon, required this.label, required this.value, required this.activeSort, this.onTap});

  @override
  Widget build(BuildContext context) {
    final on = value == activeSort;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: on ? AppColors.navy : AppColors.fieldBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: on ? Colors.white : AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

// ─── Empty / Error ────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String search;
  final String sort;
  const _EmptyView({required this.search, required this.sort});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.06), shape: BoxShape.circle),
        child: const Icon(Icons.search_off_rounded, size: 30, color: AppColors.textHint),
      ),
      const SizedBox(height: 16),
      Text(
        sort == 'near_me' ? 'No lawyers found near you' : search.isEmpty ? 'No lawyers found' : 'No results for "$search"',
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
      const SizedBox(height: 6),
      Text('Try a different name, category, or filter.',
        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
    ]),
  ));
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.textHint),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      GestureDetector(onTap: onRetry, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
        child: Text('Retry', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      )),
    ]),
  ));
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';

class LawyerLoginScreen extends StatefulWidget {
  const LawyerLoginScreen({super.key});

  @override
  State<LawyerLoginScreen> createState() => _LawyerLoginScreenState();
}

class _LawyerLoginScreenState extends State<LawyerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
        } else if (state is AuthLawyerPending) {
          _showPendingDialog();
        } else if (state is AuthError) {
          AppSnackbar.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    Text('WAKEELL PRO',
                      style: GoogleFonts.outfit(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 2.5,
                      )),
                  ],
                ),
              ),

              // ── Navy hero section ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text('LEGAL PROFESSIONAL PORTAL',
                            style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Welcome\nBack, Counselor.',
                      style: GoogleFonts.outfit(
                        fontSize: 32, fontWeight: FontWeight.w700,
                        color: Colors.white, height: 1.15,
                      )),
                    const SizedBox(height: 10),
                    Text('Sign in to access your dashboard, client bookings,\nand active sessions.',
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), height: 1.6)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // ── White card ────────────────────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sign In',
                            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('Enter your registered credentials below.',
                            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 28),

                          // Email
                          const _FieldLabel(label: 'EMAIL ADDRESS'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'name@lawfirm.com',
                              prefixIcon: Icon(Icons.alternate_email, size: 18),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const _FieldLabel(label: 'PASSWORD'),
                              GestureDetector(
                                child: Text('Forgot Password?',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.navyMid, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline, size: 18),
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textSecondary, size: 20,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Login button
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return GestureDetector(
                                onTap: isLoading ? null : _submit,
                                child: Container(
                                  width: double.infinity, height: 52,
                                  decoration: BoxDecoration(
                                    color: isLoading ? AppColors.navy.withValues(alpha: 0.6) : AppColors.navy,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: isLoading ? [] : [
                                      BoxShadow(color: AppColors.navy.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                                    ],
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Sign In', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
                                            ],
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 28),

                          // Divider
                          Row(children: [
                            const Expanded(child: Divider(color: AppColors.divider)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('OR', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                            ),
                            const Expanded(child: Divider(color: AppColors.divider)),
                          ]),
                          const SizedBox(height: 20),

                          // Apply link
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.registerLawyer),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.fieldBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.balance_outlined, size: 18, color: AppColors.navy),
                                    const SizedBox(width: 10),
                                    Text("Don't have an account? ", style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
                                    Text('Apply Now', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Security note
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.verified_user_outlined, size: 13, color: AppColors.textHint),
                                const SizedBox(width: 5),
                                Text('Bank-grade encrypted session',
                                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPendingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.hourglass_top_rounded, color: AppColors.navy, size: 30),
            ),
            const SizedBox(height: 20),
            Text('Account Under Review',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text('Your application is being verified by our compliance team. You will be notified once approved.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, height: 46,
                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text('OK', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8),
      );
}

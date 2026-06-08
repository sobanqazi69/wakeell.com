import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../cubits/review_cubit.dart';
import '../cubits/review_state.dart';

class ReviewScreen extends StatefulWidget {
  final int bookingId;
  final String lawyerName;

  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.lawyerName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ReviewCubit>().load(widget.bookingId);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: BlocConsumer<ReviewCubit, ReviewState>(
          listener: (context, state) {
            if (state is ReviewSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Review submitted!',
                      style: GoogleFonts.outfit(color: Colors.white)),
                  backgroundColor: const Color(0xFF16A34A),
                ),
              );
              Navigator.of(context).pop();
            }
            if (state is ReviewError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message,
                      style: GoogleFonts.outfit(color: Colors.white)),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReviewState state) {
    if (state is ReviewLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
    }
    if (state is ReviewAlreadySubmitted) {
      return _buildAlreadyReviewed(context, state);
    }
    return _buildForm(context, state);
  }

  Widget _buildAlreadyReviewed(BuildContext context, ReviewAlreadySubmitted state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          _buildHeader(context),
          const Spacer(),
          const Icon(Icons.check_circle_outline, color: AppColors.cyan, size: 64),
          const SizedBox(height: 20),
          Text('Already Reviewed',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Text('You already rated this session ${state.review.rating} stars',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
          const Spacer(),
          _buildDoneButton(context),
        ]),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ReviewState state) {
    final selectedRating = state is ReviewReady ? state.selectedRating : 0;
    final isSubmitting = state is ReviewSubmitting;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(context),
          const SizedBox(height: 32),

          // Session complete badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 16),
                const SizedBox(width: 6),
                Text('Session Completed',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A))),
              ]),
            ),
          ),
          const SizedBox(height: 32),

          // Lawyer name
          Center(
            child: Text('How was your session with',
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(widget.lawyerName,
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(height: 32),

          // Star rating
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => context.read<ReviewCubit>().setRating(star),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      star <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: star <= selectedRating ? const Color(0xFFD4A843) : AppColors.textSecondary,
                      size: 44,
                    ),
                  ),
                );
              }),
            ),
          ),
          if (selectedRating > 0) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(_ratingLabel(selectedRating),
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFD4A843))),
            ),
          ],
          const SizedBox(height: 32),

          // Comment field
          Text('Your feedback (optional)',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: TextField(
              controller: _commentCtrl,
              maxLines: 4,
              maxLength: 500,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Share your experience with this lawyer…',
                hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                counterStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Submit button
          GestureDetector(
            onTap: isSubmitting || selectedRating == 0
                ? null
                : () => context.read<ReviewCubit>().submit(
                      bookingId: widget.bookingId,
                      rating: selectedRating,
                      comment: _commentCtrl.text.trim(),
                    ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 52,
              decoration: BoxDecoration(
                gradient: selectedRating > 0
                    ? const LinearGradient(colors: [AppColors.navy, AppColors.purple])
                    : null,
                color: selectedRating == 0 ? AppColors.fieldBorder : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isSubmitting
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        selectedRating == 0 ? 'Select a rating first' : 'Submit Review',
                        style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: selectedRating > 0 ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Skip
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text('Skip for now',
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary,
                      decoration: TextDecoration.underline)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(children: [
      GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 18),
        ),
      ),
      const SizedBox(width: 12),
      Text('Rate Your Session',
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
    ]);
  }

  Widget _buildDoneButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        height: 52, width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.navy, AppColors.purple]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text('Done',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
}

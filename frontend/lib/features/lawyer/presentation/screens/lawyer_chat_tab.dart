import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';

class LawyerChatTab extends StatelessWidget {
  const LawyerChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Messages', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Chat with your clients', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
            ])),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.fieldBorder)),
              child: const Icon(Icons.edit_outlined, size: 17, color: AppColors.textSecondary),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 44,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.fieldBorder)),
            child: Row(children: [
              const SizedBox(width: 14),
              const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text('Search conversations…', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textHint)),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        // Empty state
        Expanded(child: Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.06), shape: BoxShape.circle),
              child: const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: AppColors.navy),
            ),
            const SizedBox(height: 20),
            Text('No conversations yet', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'When clients book a consultation, you can chat with them here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.access_time_outlined, size: 14, color: AppColors.navy),
                const SizedBox(width: 6),
                Text('Chat coming soon', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy)),
              ]),
            ),
          ]),
        ))),
      ]),
    );
  }
}

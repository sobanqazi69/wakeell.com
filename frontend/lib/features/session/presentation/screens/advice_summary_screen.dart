import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/session_repository.dart';
import '../../../../core/services/service_locator.dart';

class AdviceSummaryScreen extends StatefulWidget {
  final int bookingId;
  final String clientName;

  const AdviceSummaryScreen({
    super.key,
    required this.bookingId,
    required this.clientName,
  });

  @override
  State<AdviceSummaryScreen> createState() => _AdviceSummaryScreenState();
}

class _AdviceSummaryScreenState extends State<AdviceSummaryScreen> {
  static const _tag = 'AdviceSummaryScreen';
  final _ctrl = TextEditingController();
  bool _saving = false;
  bool _saved = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please write a summary before saving.',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    try {
      setState(() => _saving = true);
      await getIt<SessionRepository>().writeSummary(widget.bookingId, text);
      if (mounted) {
        setState(() {
          _saving = false;
          _saved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Advice summary saved.',
              style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      DebugLogger.error(_tag, 'save: $e');
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save summary.',
              style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // Header
        Container(
          color: AppColors.navy,
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 12, 20, 24),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Advice Summary',
                        style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text('For: ${widget.clientName}',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.white60)),
                  ]),
            ),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.navy.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16, color: AppColors.navy),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Write a concise summary of the legal advice you provided. This is visible only to you and helps keep your consultations organized.',
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppColors.navy,
                                  height: 1.5),
                            ),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 20),

                  Text('Session Notes',
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.fieldBorder),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      maxLines: 14,
                      style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.6),
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Client came with a property dispute. Advised them to gather ownership documents and approach a civil court. Key points:\n• Register the complaint within 30 days\n• Obtain NOC from local authority\n• Consider mediation first',
                        hintStyle: GoogleFonts.outfit(
                            color: AppColors.textHint,
                            fontSize: 13,
                            height: 1.6),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (_saved)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 10),
                        Text('Summary saved successfully.',
                            style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success)),
                      ]),
                    )
                  else
                    GestureDetector(
                      onTap: _saving ? null : _save,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _saving
                              ? AppColors.fieldBorder
                              : AppColors.navy,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.save_outlined,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Save Summary',
                                        style: GoogleFonts.outfit(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                ]),
          ),
        ),
      ]),
    );
  }
}

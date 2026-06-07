import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/app_colors.dart';

/// Tap-to-open city field. Shows a searchable bottom sheet.
class CityPickerField extends StatelessWidget {
  final String? value;
  final List<String> cities;
  final bool isLoading;
  final ValueChanged<String> onSelected;

  const CityPickerField({
    super.key,
    required this.value,
    required this.cities,
    required this.isLoading,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
              final picked = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _CityPickerSheet(cities: cities),
              );
              if (picked != null) onSelected(picked);
            },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.fieldBorder),
          boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 8, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: value != null ? AppColors.navy : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: isLoading
                  ? Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Loading cities…',
                          style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 14),
                        ),
                      ],
                    )
                  : Text(
                      value ?? 'Select city, Pakistan',
                      style: GoogleFonts.outfit(
                        color: value != null ? AppColors.textPrimary : AppColors.textHint,
                        fontSize: 14,
                        fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _CityPickerSheet extends StatefulWidget {
  final List<String> cities;
  const _CityPickerSheet({required this.cities});

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.cities;
    _searchCtrl.addListener(_onSearch);
    // Auto-focus the search bar
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? widget.cities
          : widget.cities.where((c) => c.toLowerCase().contains(q)).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.fieldBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select City',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${widget.cities.length} cities available',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.fieldBorder),
                    ),
                    child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search city or town…',
                  hintStyle: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _searchCtrl.clear(),
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

          // Divider
          const Divider(color: AppColors.divider, height: 1),

          // City list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off_outlined, size: 40, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          'No cities found',
                          style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Try a different spelling',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filtered.length,
                    separatorBuilder: (ctx, i) => const Divider(color: AppColors.divider, height: 1, indent: 20, endIndent: 20),
                    itemBuilder: (context, index) {
                      final city = _filtered[index];
                      final isOther = city == 'Other';
                      return _CityTile(
                        city: city,
                        isOther: isOther,
                        query: _searchCtrl.text.trim(),
                        onTap: () => Navigator.pop(context, city),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Single city row ──────────────────────────────────────────────────────────

class _CityTile extends StatelessWidget {
  final String city;
  final bool isOther;
  final String query;
  final VoidCallback onTap;

  const _CityTile({
    required this.city,
    required this.isOther,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isOther
                    ? AppColors.navy.withValues(alpha: 0.08)
                    : AppColors.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isOther ? Icons.edit_location_alt_outlined : Icons.location_city_outlined,
                size: 16,
                color: isOther ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: query.isEmpty || isOther
                  ? Text(
                      city,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: isOther ? FontWeight.w600 : FontWeight.normal,
                        color: isOther ? AppColors.navy : AppColors.textPrimary,
                      ),
                    )
                  : _HighlightedText(text: city, query: query),
            ),
            if (isOther)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Custom',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.navy),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Highlight matching text ──────────────────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary));
    }

    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final start = lower.indexOf(q);
    if (start < 0) {
      return Text(text, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary));
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary),
        children: [
          if (start > 0) TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, start + q.length),
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              backgroundColor: AppColors.navy.withValues(alpha: 0.08),
            ),
          ),
          if (start + q.length < text.length)
            TextSpan(text: text.substring(start + q.length)),
        ],
      ),
    );
  }
}

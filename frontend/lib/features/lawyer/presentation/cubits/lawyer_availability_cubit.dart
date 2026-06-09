import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/lawyer_repository.dart';
import 'lawyer_availability_state.dart';

class LawyerAvailabilityCubit extends Cubit<LawyerAvailabilityState> {
  static const _tag = 'LawyerAvailabilityCubit';
  final LawyerRepository _repo;

  LawyerAvailabilityCubit(this._repo) : super(const LawyerAvailabilityInitial());

  Future<void> load() async {
    try {
      if (!isClosed) emit(const LawyerAvailabilityLoading());
      final profile      = await _repo.getMyProfile();
      final availability = await _repo.getAvailability(profile.id);

      if (availability.isEmpty) {
        if (!isClosed) emit(LawyerAvailabilityLoaded(_defaultSchedule()));
        return;
      }

      // Convert date-keyed slots → day-of-week-keyed (0=Mon … 6=Sun).
      // The same weekday recurs every week; take the first occurrence of each.
      final schedule = <int, List<String>>{};
      final sortedDates = availability.keys.toList()..sort();
      for (final dateStr in sortedDates) {
        try {
          final dayIndex = DateTime.parse(dateStr).weekday - 1;
          schedule.putIfAbsent(dayIndex, () => availability[dateStr]!);
        } catch (_) {}
      }

      if (!isClosed) emit(LawyerAvailabilityLoaded(schedule));
    } catch (e) {
      DebugLogger.error(_tag, 'load: $e');
      // Fall back to default so the screen is always usable
      if (!isClosed) emit(LawyerAvailabilityLoaded(_defaultSchedule()));
    }
  }

  void startEdit() {
    if (!isClosed) emit(LawyerAvailabilityLoaded(_defaultSchedule()));
  }

  Map<int, List<String>> _defaultSchedule() {
    return {
      for (int i = 0; i < 7; i++) i: i < 5 ? ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'] : [],
    };
  }

  void toggleSlot(int dayIndex, String slot) {
    final current = state;
    if (current is! LawyerAvailabilityLoaded) return;
    final updated = Map<int, List<String>>.from(
      current.schedule.map((k, v) => MapEntry(k, List<String>.from(v))),
    );
    final daySlots = updated[dayIndex] ?? [];
    daySlots.contains(slot) ? daySlots.remove(slot) : daySlots.add(slot);
    updated[dayIndex] = daySlots;
    if (!isClosed) emit(LawyerAvailabilityLoaded(updated));
  }

  void clearDay(int dayIndex) {
    final current = state;
    if (current is! LawyerAvailabilityLoaded) return;
    final updated = Map<int, List<String>>.from(
      current.schedule.map((k, v) => MapEntry(k, List<String>.from(v))),
    );
    updated[dayIndex] = [];
    if (!isClosed) emit(LawyerAvailabilityLoaded(updated));
  }

  Future<void> save(Map<int, List<String>> schedule) async {
    try {
      if (!isClosed) emit(const LawyerAvailabilitySaving());

      // Generate next 4 weeks of dates
      final entries = <Map<String, dynamic>>[];
      final now = DateTime.now();
      for (int week = 0; week < 4; week++) {
        for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
          final slots = schedule[dayIndex] ?? [];
          if (slots.isEmpty) continue;

          // dayIndex 0=Mon, 6=Sun. DateTime weekday: 1=Mon, 7=Sun
          final targetWeekday = dayIndex + 1;
          final daysUntil = (targetWeekday - now.weekday + 7) % 7 + (week * 7);
          final date = now.add(Duration(days: daysUntil));
          final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          entries.add({'date': dateStr, 'slots': slots});
        }
      }

      await _repo.setAvailability(entries);
      if (!isClosed) emit(const LawyerAvailabilitySaved());
      // Restore loaded state
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!isClosed) emit(LawyerAvailabilityLoaded(schedule));
    } on LawyerException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerAvailabilityError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'save: $e');
      if (!isClosed) emit(const LawyerAvailabilityError('Failed to save availability'));
    }
  }
}

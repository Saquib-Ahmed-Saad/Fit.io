import '../models/habit_log.dart';

/// Computes streak and weekly completion metrics from a list of logs.
/// Original structure by Saquib Ahmed.
/// Bug fix by Brendon Huang: completionDate is now DateTime so
/// .year/.month/.day access is valid; removed String parsing.
class HabitMetricsService {
  int currentStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;

    // Build a set of completed date strings for fast lookup
    final completedDays = <String>{
      for (final log in logs)
        if (log.status) _dayKey(log.completionDate),
    };

    final today  = DateTime.now();
    var   cursor = DateTime(today.year, today.month, today.day);
    var   streak = 0;

    while (completedDays.contains(_dayKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Returns a 7-element list: completions per day for the last 7 days,
  /// starting from 6 days ago (index 0) through today (index 6).
  List<int> weeklyCompletions(List<HabitLog> logs) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));

    final buckets = List<int>.filled(7, 0);

    for (final log in logs) {
      if (!log.status) continue;

      final day        = DateTime(
        log.completionDate.year,
        log.completionDate.month,
        log.completionDate.day,
      );
      final difference = day.difference(start).inDays;
      if (difference >= 0 && difference < 7) {
        buckets[difference] += 1;
      }
    }

    return buckets;
  }

  String _dayKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

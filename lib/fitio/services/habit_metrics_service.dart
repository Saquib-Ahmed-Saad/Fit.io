import '../models/habit_log.dart';

class HabitMetricsService {
  int currentStreak(List<HabitLog> logs) {
    if (logs.isEmpty) {
      return 0;
    }

    final byDate = <String, bool>{
      for (final log in logs) _dateOnly(log.completionDate): log.status,
    };

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    var streak = 0;

    while (byDate[_dateOnly(cursor)] ?? false) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  List<int> weeklyCompletions(List<HabitLog> logs) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));

    final buckets = List<int>.filled(7, 0);

    for (final log in logs) {
      if (!log.status) {
        continue;
      }
      final day = DateTime(
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

  String _dateOnly(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

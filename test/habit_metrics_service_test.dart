import 'package:flutter_test/flutter_test.dart';
import 'package:fit_io/fitio/models/habit_log.dart';
import 'package:fit_io/fitio/services/habit_metrics_service.dart';

void main() {
  final service = HabitMetricsService();

  test('currentStreak returns consecutive days including today', () {
    final now = DateTime.now();
    final logs = <HabitLog>[
      HabitLog(habitId: 1, completionDate: now, status: true),
      HabitLog(
        habitId: 1,
        completionDate: now.subtract(const Duration(days: 1)),
        status: true,
      ),
      HabitLog(
        habitId: 1,
        completionDate: now.subtract(const Duration(days: 2)),
        status: true,
      ),
    ];

    expect(service.currentStreak(logs), 3);
  });

  test('weeklyCompletions returns seven days with total hits', () {
    final now = DateTime.now();
    final logs = <HabitLog>[
      HabitLog(habitId: 1, completionDate: now, status: true),
      HabitLog(
        habitId: 2,
        completionDate: now.subtract(const Duration(days: 1)),
        status: true,
      ),
      HabitLog(
        habitId: 3,
        completionDate: now.subtract(const Duration(days: 6)),
        status: true,
      ),
    ];

    final values = service.weeklyCompletions(logs);

    expect(values.length, 7);
    expect(values.reduce((int a, int b) => a + b), 3);
  });
}

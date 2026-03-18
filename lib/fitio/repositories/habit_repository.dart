import '../data/fitio_database.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

/// Repository that Saquib's screens and AppController use.
///
/// Original structure by Saquib Ahmed.
/// Bug fixes and additions by Brendon Huang:
///   - Fixed toIso8601String() → yyyy-MM-dd format so queries match storage
///   - Fixed completionDate type (now DateTime, not String)
///   - Added archiveHabit, unmarkHabitComplete
class HabitRepository {
  HabitRepository({FitioDatabase? database})
      : _database = database ?? FitioDatabase.instance;

  final FitioDatabase _database;

  // Habits

  Future<List<Habit>> getHabits() => _database.getHabits();

  Future<int> createHabit(Habit habit) => _database.createHabit(habit);

  Future<int> updateHabit(Habit habit) => _database.updateHabit(habit);

  Future<int> archiveHabit(int habitId) => _database.archiveHabit(habitId);

  Future<int> deleteHabit(int habitId) => _database.deleteHabit(habitId);

  // Logs

  Future<List<HabitLog>> getLogsForHabit(int habitId) =>
      _database.getLogsForHabit(habitId);

  Future<List<HabitLog>> getAllLogs() => _database.getAllLogs();

  /// Mark a habit complete for the given date (time component is stripped).
  Future<void> markHabitComplete({
    required int habitId,
    required DateTime date,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    await _database.upsertLog(
      HabitLog(habitId: habitId, completionDate: day, status: true),
    );
  }

  /// Remove a completion mark for the given date.
  Future<void> unmarkHabitComplete({
    required int habitId,
    required DateTime date,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    await _database.upsertLog(
      HabitLog(habitId: habitId, completionDate: day, status: false),
    );
  }

  Future<bool> isHabitCompletedOnDate({
    required int habitId,
    required DateTime date,
  }) =>
      _database.isCompletedOnDate(habitId, date);

  Future<void> clearAllData() => _database.clearAllData();
}

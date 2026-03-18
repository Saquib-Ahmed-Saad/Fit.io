import 'package:sqflite/sqflite.dart';

import '../data/fitio_database.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class HabitRepository {
  HabitRepository({FitioDatabase? database})
      : _database = database ?? FitioDatabase.instance;

  final FitioDatabase _database;

  Future<List<Habit>> getHabits() async {
    final db = await _database.database;
    final rows = await db.query(
      'habits',
      where: 'is_archived = ?',
      whereArgs: <Object>[0],
      orderBy: 'created_date DESC',
    );
    return rows.map(Habit.fromMap).toList(growable: false);
  }

  Future<int> createHabit(Habit habit) async {
    final db = await _database.database;
    return db.insert('habits', habit.toMap());
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await _database.database;
    return db.update(
      'habits',
      habit.toMap(),
      where: 'habit_id = ?',
      whereArgs: <Object>[habit.id ?? -1],
    );
  }

  Future<int> deleteHabit(int habitId) async {
    final db = await _database.database;
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: <Object>[habitId]);
    return db.delete('habits', where: 'habit_id = ?', whereArgs: <Object>[habitId]);
  }

  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    final db = await _database.database;
    final rows = await db.query(
      'habit_logs',
      where: 'habit_id = ?',
      whereArgs: <Object>[habitId],
      orderBy: 'completion_date DESC',
    );
    return rows.map(HabitLog.fromMap).toList(growable: false);
  }

  Future<List<HabitLog>> getAllLogs() async {
    final db = await _database.database;
    final rows = await db.query('habit_logs', orderBy: 'completion_date DESC');
    return rows.map(HabitLog.fromMap).toList(growable: false);
  }

  Future<void> markHabitComplete({required int habitId, required DateTime date}) async {
    final db = await _database.database;
    final day = DateTime(date.year, date.month, date.day).toIso8601String();

    await db.insert(
      'habit_logs',
      HabitLog(habitId: habitId, completionDate: DateTime.parse(day), status: true).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isHabitCompletedOnDate({required int habitId, required DateTime date}) async {
    final db = await _database.database;
    final day = DateTime(date.year, date.month, date.day).toIso8601String();
    final rows = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND completion_date = ? AND status = ?',
      whereArgs: <Object>[habitId, day, 1],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> clearAllData() async {
    final db = await _database.database;
    await db.delete('habit_logs');
    await db.delete('habits');
  }
}

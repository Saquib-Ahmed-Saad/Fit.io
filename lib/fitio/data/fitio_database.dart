import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';

/// Singleton SQLite database for Fit.io.
///
/// Schema by Saquib Ahmed.
/// CRUD methods added by Brendon Huang.
class FitioDatabase {
  FitioDatabase._();

  static final FitioDatabase instance = FitioDatabase._();

  static const String _databaseName = 'fitio.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _databaseName);
    _database = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        habit_id     INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_name   TEXT    NOT NULL,
        description  TEXT    NOT NULL,
        frequency    TEXT    NOT NULL,
        created_date TEXT    NOT NULL,
        is_archived  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        log_id          INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id        INTEGER NOT NULL,
        completion_date TEXT    NOT NULL,
        status          INTEGER NOT NULL,
        UNIQUE(habit_id, completion_date),
        FOREIGN KEY(habit_id) REFERENCES habits(habit_id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_logs_date ON habit_logs(completion_date)',
    );
  }

  // HABITS

  Future<int> createHabit(Habit habit) async {
    final db = await database;
    return db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getHabits() async {
    final db   = await database;
    final rows = await db.query(
      'habits',
      where:    'is_archived = ?',
      whereArgs: [0],
      orderBy:  'created_date DESC',
    );
    return rows.map(Habit.fromMap).toList(growable: false);
  }

  Future<Habit?> getHabit(int id) async {
    final db   = await database;
    final rows = await db.query(
      'habits',
      where:    'habit_id = ?',
      whereArgs: [id],
      limit:    1,
    );
    return rows.isEmpty ? null : Habit.fromMap(rows.first);
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return db.update(
      'habits',
      habit.toMap(),
      where:    'habit_id = ?',
      whereArgs: [habit.id ?? -1],
    );
  }

  Future<int> archiveHabit(int id) async {
    final db = await database;
    return db.update(
      'habits',
      {'is_archived': 1},
      where:    'habit_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
    return db.delete('habits',    where: 'habit_id = ?', whereArgs: [id]);
  }

  // HABIT LOGS

  /// Insert or replace a log entry.
  Future<int> upsertLog(HabitLog log) async {
    final db = await database;
    return db.insert(
      'habit_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    final db   = await database;
    final rows = await db.query(
      'habit_logs',
      where:    'habit_id = ?',
      whereArgs: [habitId],
      orderBy:  'completion_date DESC',
    );
    return rows.map(HabitLog.fromMap).toList(growable: false);
  }

  Future<List<HabitLog>> getAllLogs() async {
    final db   = await database;
    final rows = await db.query('habit_logs', orderBy: 'completion_date DESC');
    return rows.map(HabitLog.fromMap).toList(growable: false);
  }

  Future<bool> isCompletedOnDate(int habitId, DateTime date) async {
    final db  = await database;
    final day = _fmt(date);
    final rows = await db.query(
      'habit_logs',
      where:    'habit_id = ? AND completion_date = ? AND status = ?',
      whereArgs: [habitId, day, 1],
      limit:    1,
    );
    return rows.isNotEmpty;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('habit_logs');
    await db.delete('habits');
  }

  // HELPERS
  /// Formats DateTime as 'yyyy-MM-dd' for consistent SQLite storage.
  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> close() async {
    final db = _database;
    if (db != null) await db.close();
    _database = null;
  }
}

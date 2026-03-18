import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class FitioDatabase {
  FitioDatabase._();

  static final FitioDatabase instance = FitioDatabase._();

  static const String _databaseName = 'fitio.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

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
        habit_id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_name TEXT NOT NULL,
        description TEXT NOT NULL,
        frequency TEXT NOT NULL,
        created_date TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        log_id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        completion_date TEXT NOT NULL,
        status INTEGER NOT NULL,
        UNIQUE(habit_id, completion_date),
        FOREIGN KEY(habit_id) REFERENCES habits(habit_id) ON DELETE CASCADE
      )
    ''');
  }
}

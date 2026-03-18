// Unit tests for FitioDatabase CRUD operations.
// Author: Brendon Huang — Navigation, Testing, Documentation
// Uses sqflite_common_ffi so these run on desktop with no emulator needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fit_io/fitio/data/fitio_database.dart';
import 'package:fit_io/fitio/models/habit.dart';
import 'package:fit_io/fitio/models/habit_log.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final db = FitioDatabase.instance;

  // Helpers

  DateTime ago(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    return DateTime(d.year, d.month, d.day);
  }

  Habit makeHabit({String name = 'Test Habit', String freq = 'Daily'}) =>
      Habit(
        name:        name,
        description: 'A test habit',
        frequency:   freq,
        createdDate: ago(0),
      );

  // GROUP 1: Habits CREATE

  group('Habits — CREATE', () {
    test('1. createHabit returns a positive integer ID', () async {
      final id = await db.createHabit(makeHabit(name: 'Create Test'));
      expect(id, greaterThan(0));
    });

    test('2. createHabit stores name and description correctly', () async {
      final habit = Habit(
        name:        'Read 20 Pages',
        description: 'Read every morning',
        frequency:   'Daily',
        createdDate: ago(0),
      );
      final id      = await db.createHabit(habit);
      final fetched = await db.getHabit(id);
      expect(fetched?.name,        equals('Read 20 Pages'));
      expect(fetched?.description, equals('Read every morning'));
    });

    test('3. createHabit defaults is_archived to false', () async {
      final id = await db.createHabit(makeHabit(name: 'Archive Default'));
      final h  = await db.getHabit(id);
      expect(h?.isArchived, isFalse);
    });
  });

  // GROUP 2: Habits READ

  group('Habits — READ', () {
    test('4. getHabits returns only non-archived habits', () async {
      final id1 = await db.createHabit(makeHabit(name: 'Active A'));
      final id2 = await db.createHabit(makeHabit(name: 'Active B'));
      await db.archiveHabit(id1);
      final habits = await db.getHabits();
      final ids    = habits.map((h) => h.id).toList();
      expect(ids, isNot(contains(id1)));
      expect(ids, contains(id2));
    });

    test('5. getHabit returns correct habit by ID', () async {
      final id = await db.createHabit(makeHabit(name: 'Meditate Daily'));
      final h  = await db.getHabit(id);
      expect(h,      isNotNull);
      expect(h!.id,  equals(id));
      expect(h.name, equals('Meditate Daily'));
    });

    test('6. getHabit returns null for non-existent ID', () async {
      final h = await db.getHabit(999999);
      expect(h, isNull);
    });
  });

  // GROUP 3: Habits UPDATE

  group('Habits — UPDATE', () {
    test('7. updateHabit persists new name', () async {
      final id = await db.createHabit(makeHabit(name: 'Old Name'));
      final h  = await db.getHabit(id);
      await db.updateHabit(h!.copyWith(name: 'New Name'));
      final updated = await db.getHabit(id);
      expect(updated?.name, equals('New Name'));
    });

    test('8. updateHabit changes frequency', () async {
      final id = await db.createHabit(makeHabit(name: 'Freq Test'));
      final h  = await db.getHabit(id);
      await db.updateHabit(h!.copyWith(frequency: 'Weekly'));
      final updated = await db.getHabit(id);
      expect(updated?.frequency, equals('Weekly'));
    });
  });

  // GROUP 4: Habits DELETE / ARCHIVE

  group('Habits — DELETE / ARCHIVE', () {
    test('9. archiveHabit hides habit from getHabits', () async {
      final id = await db.createHabit(makeHabit(name: 'ToArchive'));
      await db.archiveHabit(id);
      final habits = await db.getHabits();
      expect(habits.map((h) => h.id), isNot(contains(id)));
    });

    test('10. deleteHabit permanently removes the habit', () async {
      final id = await db.createHabit(makeHabit(name: 'ToDelete'));
      await db.deleteHabit(id);
      final h = await db.getHabit(id);
      expect(h, isNull);
    });

    test('11. deleteHabit cascades and removes all logs', () async {
      final id = await db.createHabit(makeHabit(name: 'CascadeTest'));
      await db.upsertLog(HabitLog(habitId: id, completionDate: ago(0)));
      await db.upsertLog(HabitLog(habitId: id, completionDate: ago(1)));
      await db.deleteHabit(id);
      final logs = await db.getLogsForHabit(id);
      expect(logs, isEmpty);
    });
  });

  // GROUP 5: Habit Logs

  group('Habit Logs', () {
    test('12. upsertLog marks habit as completed for today', () async {
      final id = await db.createHabit(makeHabit(name: 'Log Today'));
      await db.upsertLog(HabitLog(habitId: id, completionDate: ago(0)));
      final done = await db.isCompletedOnDate(id, ago(0));
      expect(done, isTrue);
    });

    test('13. log for past date does not affect today', () async {
      final id = await db.createHabit(makeHabit(name: 'Past Log'));
      await db.upsertLog(HabitLog(habitId: id, completionDate: ago(3)));
      final done = await db.isCompletedOnDate(id, ago(0));
      expect(done, isFalse);
    });

    test('14. UNIQUE constraint prevents duplicate entries for same date',
        () async {
      final id = await db.createHabit(makeHabit(name: 'Duplicate'));
      await db.upsertLog(HabitLog(habitId: id, completionDate: ago(0)));
      await db.upsertLog(HabitLog(habitId: id, completionDate: ago(0)));
      final logs  = await db.getLogsForHabit(id);
      final today = logs.where((l) => l.status).length;
      expect(today, equals(1));
    });

    test('15. upsertLog with status=false marks as not completed', () async {
      final id = await db.createHabit(makeHabit(name: 'Toggle'));
      await db.upsertLog(
          HabitLog(habitId: id, completionDate: ago(0), status: true));
      await db.upsertLog(
          HabitLog(habitId: id, completionDate: ago(0), status: false));
      final done = await db.isCompletedOnDate(id, ago(0));
      expect(done, isFalse);
    });
  });

  // GROUP 6: getAllLogs

  group('getAllLogs', () {
    test('16. getAllLogs returns logs across all habits', () async {
      final id1 = await db.createHabit(makeHabit(name: 'AllLogs A'));
      final id2 = await db.createHabit(makeHabit(name: 'AllLogs B'));
      await db.upsertLog(HabitLog(habitId: id1, completionDate: ago(0)));
      await db.upsertLog(HabitLog(habitId: id2, completionDate: ago(0)));
      final all = await db.getAllLogs();
      final ids = all.map((l) => l.habitId).toList();
      expect(ids, containsAll([id1, id2]));
    });
  });

  // GROUP 7: clearAllData

  group('clearAllData', () {
    test('17. clearAllData removes all habits and logs', () async {
      await db.createHabit(makeHabit(name: 'ClearTest'));
      await db.clearAllData();
      final habits = await db.getHabits();
      final logs   = await db.getAllLogs();
      expect(habits, isEmpty);
      expect(logs,   isEmpty);
    });
  });

  // GROUP 8: Model serialisation

  group('Model round-trip', () {
    test('18. Habit createdDate survives toMap/fromMap round-trip', () async {
      final now   = DateTime(2026, 3, 18);
      final habit = Habit(
        name: 'RoundTrip', description: '', frequency: 'Daily',
        createdDate: now,
      );
      final id      = await db.createHabit(habit);
      final fetched = await db.getHabit(id);
      expect(fetched?.createdDate.year,  equals(2026));
      expect(fetched?.createdDate.month, equals(3));
      expect(fetched?.createdDate.day,   equals(18));
    });

    test('19. HabitLog completionDate survives toMap/fromMap round-trip',
        () async {
      final id  = await db.createHabit(makeHabit(name: 'LogRoundTrip'));
      final day = DateTime(2026, 3, 15);
      await db.upsertLog(HabitLog(habitId: id, completionDate: day));
      final logs = await db.getLogsForHabit(id);
      expect(logs.first.completionDate.year,  equals(2026));
      expect(logs.first.completionDate.month, equals(3));
      expect(logs.first.completionDate.day,   equals(15));
    });

    test('20. getHabits only returns active (non-archived) habits', () async {
      await db.clearAllData();
      final id1 = await db.createHabit(makeHabit(name: 'Active'));
      final id2 = await db.createHabit(makeHabit(name: 'Archived'));
      await db.archiveHabit(id2);
      final habits = await db.getHabits();
      expect(habits.length,              equals(1));
      expect(habits.first.id,            equals(id1));
      expect(habits.every((h) => !h.isArchived), isTrue);
    });
  });
}

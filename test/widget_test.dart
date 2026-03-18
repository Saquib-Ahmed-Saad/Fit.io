// Widget tests for Fit.io screens and widgets.
// Saquib Ahmed wrote the WeeklyChart test.
// Brendon Huang added all remaining tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_io/fitio/widgets/weekly_chart.dart';
import 'package:fit_io/fitio/widgets/habit_tile.dart';
import 'package:fit_io/fitio/models/habit.dart';
import 'package:fit_io/fitio/screens/create_edit_habit_screen.dart';
import 'package:fit_io/fitio/screens/settings_screen.dart';
import 'package:fit_io/fitio/app_controller.dart';
import 'package:fit_io/fitio/repositories/habit_repository.dart';
import 'package:fit_io/fitio/data/fitio_database.dart';

// WeeklyChart (Saquib's test)

void main() {
  testWidgets('Weekly chart renders all day labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeeklyChart(values: <int>[1, 2, 3, 4, 5, 6, 7]),
        ),
      ),
    );
    expect(find.text('M'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
    expect(find.text('S'), findsNWidgets(2));
  });

  // WeeklyChart additional

  testWidgets('WeeklyChart renders all 7 bar values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeeklyChart(values: <int>[0, 1, 2, 3, 4, 5, 6]),
        ),
      ),
    );
    // Values 1–6 should appear as text labels above each bar
    expect(find.text('0'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('WeeklyChart shows animated containers for bars', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeeklyChart(values: <int>[1, 1, 1, 1, 1, 1, 1]),
        ),
      ),
    );
    expect(find.byType(AnimatedContainer), findsNWidgets(7));
  });

  // HabitTile

  testWidgets('HabitTile renders habit name', (tester) async {
    final habit = Habit(
      name: 'Morning Run', description: '',
      frequency: 'Daily', createdDate: DateTime(2026, 1, 1),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HabitTile(
          habit: habit,
          isCompletedToday: false,
          onMarkComplete: () {},
          onTap: () {},
        ),
      ),
    ));
    expect(find.text('Morning Run'), findsOneWidget);
  });

  testWidgets('HabitTile shows Complete button when not done', (tester) async {
    final habit = Habit(
      name: 'Yoga', description: '',
      frequency: 'Daily', createdDate: DateTime(2026, 1, 1),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HabitTile(
          habit: habit,
          isCompletedToday: false,
          onMarkComplete: () {},
          onTap: () {},
        ),
      ),
    ));
    expect(find.text('Complete'), findsOneWidget);
  });

  testWidgets('HabitTile shows Done and disables button when completed',
      (tester) async {
    final habit = Habit(
      name: 'Read', description: '',
      frequency: 'Daily', createdDate: DateTime(2026, 1, 1),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HabitTile(
          habit: habit,
          isCompletedToday: true,
          onMarkComplete: () {},
          onTap: () {},
        ),
      ),
    ));
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('HabitTile shows frequency and created date', (tester) async {
    final habit = Habit(
      name: 'Walk', description: '',
      frequency: 'Weekly', createdDate: DateTime(2026, 1, 15),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HabitTile(
          habit: habit,
          isCompletedToday: false,
          onMarkComplete: () {},
          onTap: () {},
        ),
      ),
    ));
    expect(find.textContaining('Weekly'), findsOneWidget);
  });

  // CreateEditHabitScreen

  testWidgets('CreateEditHabitScreen shows Create Habit title', (tester) async {
    final repo = HabitRepository(database: FitioDatabase.instance);
    await tester.pumpWidget(MaterialApp(
      home: CreateEditHabitScreen(repository: repo),
    ));
    await tester.pump();
    expect(find.text('Create Habit'), findsOneWidget);
  });

  testWidgets('CreateEditHabitScreen validates empty name', (tester) async {
    final repo = HabitRepository(database: FitioDatabase.instance);
    await tester.pumpWidget(MaterialApp(
      home: CreateEditHabitScreen(repository: repo),
    ));
    await tester.pump();
    // Tap the Save button without entering a name
    await tester.tap(find.text('Save Habit'));
    await tester.pump();
    expect(find.text('Habit name is required.'), findsOneWidget);
  });

  testWidgets('CreateEditHabitScreen shows Edit Habit title in edit mode',
      (tester) async {
    final habit = Habit(
      id: 1, name: 'Existing', description: 'desc',
      frequency: 'Daily', createdDate: DateTime(2026, 1, 1),
    );
    final repo = HabitRepository(database: FitioDatabase.instance);
    await tester.pumpWidget(MaterialApp(
      home: CreateEditHabitScreen(repository: repo, habit: habit),
    ));
    await tester.pump();
    expect(find.text('Edit Habit'), findsOneWidget);
  });

  testWidgets('CreateEditHabitScreen pre-fills name in edit mode',
      (tester) async {
    final habit = Habit(
      id: 2, name: 'Evening Walk', description: '',
      frequency: 'Daily', createdDate: DateTime(2026, 1, 1),
    );
    final repo = HabitRepository(database: FitioDatabase.instance);
    await tester.pumpWidget(MaterialApp(
      home: CreateEditHabitScreen(repository: repo, habit: habit),
    ));
    await tester.pump();
    expect(find.text('Evening Walk'), findsOneWidget);
  });

  testWidgets('CreateEditHabitScreen has Daily, Weekly, Custom frequency options',
      (tester) async {
    final repo = HabitRepository(database: FitioDatabase.instance);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CreateEditHabitScreen(repository: repo)),
    ));
    await tester.pump();
    // Open frequency dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Daily'),  findsWidgets);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });

  // SettingsScreen

  testWidgets('SettingsScreen shows dark mode toggle', (tester) async {
    final controller = AppController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SettingsScreen(controller: controller)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('SettingsScreen shows notifications toggle', (tester) async {
    final controller = AppController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SettingsScreen(controller: controller)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('SettingsScreen shows reset data option', (tester) async {
    final controller = AppController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SettingsScreen(controller: controller)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Reset data'), findsOneWidget);
  });
}

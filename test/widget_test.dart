// Widget tests for Fit.io screens and widgets.
// Saquib Ahmed wrote the WeeklyChart test.
// Brendon Huang added all remaining tests.
//
// Run: flutter test test/widget_test.dart

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

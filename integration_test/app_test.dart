// End-to-end integration tests for Fit.io.
// Author: Brendon Huang — Navigation, Testing, Documentation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fit_io/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fit.io — Integration Tests', () {
    testWidgets('Splash screen shows app name', (tester) async {
      app.main();
      await tester.pump();
      expect(find.text('Fit.io'), findsOneWidget);
    });

    testWidgets('Splash auto-navigates to Dashboard', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('FAB on Dashboard opens Create Habit screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Create Habit'), findsOneWidget);
    });

    testWidgets('Form validation rejects empty habit name', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Habit'));
      await tester.pump();
      expect(find.text('Habit name is required.'), findsOneWidget);
    });

    testWidgets('User can create a habit end-to-end', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g. Read 20 minutes'),
          'Drink Water');
      await tester.tap(find.text('Save Habit'));
      await tester.pumpAndSettle();
      expect(find.text('Drink Water'), findsOneWidget);
    });

testWidgets('Progress tab navigates correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      expect(find.text('Weekly Completion Chart'), findsOneWidget);
    });

    testWidgets('Settings tab navigates correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Dark mode'), findsOneWidget);
    });

    testWidgets('Dark mode toggle works without crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

testWidgets('Tapping a habit opens HabitDetailsScreen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      // Create a habit first
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g. Read 20 minutes'),
          'Morning Stretch');
      await tester.tap(find.text('Save Habit'));
      await tester.pumpAndSettle();
      // Tap it
      await tester.tap(find.text('Morning Stretch'));
      await tester.pumpAndSettle();
      expect(find.text('Habit Details'), findsOneWidget);
    });

    testWidgets('Delete button shows confirmation dialog', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g. Read 20 minutes'),
          'ToDeleteHabit');
      await tester.tap(find.text('Save Habit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ToDeleteHabit'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Delete Habit'), findsOneWidget);
      expect(find.text('Cancel'),       findsOneWidget);
    });
  });
}

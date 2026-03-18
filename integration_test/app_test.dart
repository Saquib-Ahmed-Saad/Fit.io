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


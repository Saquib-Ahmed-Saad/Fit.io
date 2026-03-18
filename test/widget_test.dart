import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_io/fitio/widgets/weekly_chart.dart';

void main() {
  testWidgets('Weekly chart renders all day labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeeklyChart(values: const <int>[1, 2, 3, 4, 5, 6, 7]),
        ),
      ),
    );

    expect(find.text('M'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
    expect(find.text('S'), findsNWidgets(2));
  });
}

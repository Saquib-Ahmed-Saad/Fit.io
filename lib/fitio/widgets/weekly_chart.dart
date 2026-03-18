import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    super.key,
    required this.values,
  }) : assert(values.length == 7, 'Weekly chart needs exactly 7 values.');

  final List<int> values;

  static const List<String> _labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(1, (int prev, int item) => item > prev ? item : prev);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(values.length, (int index) {
        final ratio = values[index] / maxValue;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(values[index].toString()),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  height: 16 + (80 * ratio),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_labels[index]),
              ],
            ),
          ),
        );
      }),
    );
  }
}

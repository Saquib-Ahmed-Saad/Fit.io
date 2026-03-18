import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompletedToday,
    required this.onMarkComplete,
    required this.onTap,
  });

  final Habit habit;
  final bool isCompletedToday;
  final VoidCallback onMarkComplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('MMM d, y').format(habit.createdDate);
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(habit.name),
        subtitle: Text('${habit.frequency} · Created $dateText'),
        trailing: FilledButton.tonalIcon(
          onPressed: isCompletedToday ? null : onMarkComplete,
          icon: Icon(isCompletedToday ? Icons.check_circle : Icons.check),
          label: Text(isCompletedToday ? 'Done' : 'Complete'),
        ),
      ),
    );
  }
}

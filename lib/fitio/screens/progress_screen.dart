import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../repositories/habit_repository.dart';
import '../services/habit_metrics_service.dart';
import '../widgets/weekly_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, required this.repository});

  final HabitRepository repository;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final HabitMetricsService _metrics = HabitMetricsService();

  bool _loading = true;
  List<Habit> _habits = const <Habit>[];
  List<HabitLog> _logs = const <HabitLog>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    final habits = await widget.repository.getHabits();
    final logs = await widget.repository.getAllLogs();

    if (!mounted) {
      return;
    }

    setState(() {
      _habits = habits;
      _logs = logs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final weeklyValues = _metrics.weeklyCompletions(_logs);
    final totalCompletions = _logs.where((HabitLog log) => log.status).length;
    final activeHabits = _habits.length;
    final averagePerHabit = activeHabits == 0
        ? 0
        : (totalCompletions / activeHabits).toStringAsFixed(1);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Weekly Completion Chart', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  WeeklyChart(values: weeklyValues),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Total Completions'),
              trailing: Text(
                totalCompletions.toString(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Active Habits'),
              trailing: Text(
                activeHabits.toString(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Average Completions per Habit'),
              trailing: Text(
                averagePerHabit.toString(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Habit Performance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_habits.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Create habits to view performance summaries.'),
              ),
            )
          else
            ..._habits.map((Habit habit) {
              final id = habit.id;
              final logs = id == null
                  ? const <HabitLog>[]
                  : _logs.where((HabitLog log) => log.habitId == id && log.status).toList(growable: false);
              final streak = _metrics.currentStreak(logs);

              return Card(
                child: ListTile(
                  title: Text(habit.name),
                  subtitle: Text('${logs.length} completion(s)'),
                  trailing: Text('Streak: $streak'),
                ),
              );
            }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

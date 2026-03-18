import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../repositories/habit_repository.dart';
import '../services/habit_metrics_service.dart';
import '../widgets/habit_tile.dart';
import '../widgets/weekly_chart.dart';
import 'habit_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.repository});

  final HabitRepository repository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HabitMetricsService _metrics = HabitMetricsService();

  bool _loading = true;
  List<Habit> _habits = const <Habit>[];
  List<HabitLog> _logs = const <HabitLog>[];
  Set<int> _completedTodayHabitIds = <int>{};

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

    final todayKey = _dayKey(DateTime.now());
    final completedToday = logs
        .where((HabitLog log) => log.status && _dayKey(log.completionDate) == todayKey)
        .map((HabitLog log) => log.habitId)
        .toSet();

    if (!mounted) {
      return;
    }

    setState(() {
      _habits = habits;
      _logs = logs;
      _completedTodayHabitIds = completedToday;
      _loading = false;
    });
  }

  Future<void> _completeHabit(Habit habit) async {
    if (habit.id == null) {
      return;
    }

    await widget.repository.markHabitComplete(
      habitId: habit.id!,
      date: DateTime.now(),
    );
    await _loadData();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marked "${habit.name}" as complete for today.')),
    );
  }

  Future<void> _openDetails(Habit habit) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HabitDetailsScreen(
          repository: widget.repository,
          habit: habit,
        ),
      ),
    );

    if (updated == true) {
      await _loadData();
    }
  }

  DashboardSummary _buildSummary() {
    var longestStreak = 0;
    for (final habit in _habits) {
      final habitId = habit.id;
      if (habitId == null) {
        continue;
      }
      final streak = _metrics.currentStreak(
        _logs.where((HabitLog log) => log.habitId == habitId).toList(growable: false),
      );
      if (streak > longestStreak) {
        longestStreak = streak;
      }
    }

    return DashboardSummary(
      totalHabits: _habits.length,
      completedToday: _completedTodayHabitIds.length,
      longestCurrentStreak: longestStreak,
      weeklyCompletions: _metrics.weeklyCompletions(_logs),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = _buildSummary();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _SummaryCards(summary: summary),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('This Week', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  WeeklyChart(values: summary.weeklyCompletions),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Habits', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_habits.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'No habits yet. Tap "Add Habit" to create your first one.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          else
            ..._habits.map((Habit habit) {
              final id = habit.id;
              final completed = id != null && _completedTodayHabitIds.contains(id);
              return HabitTile(
                habit: habit,
                isCompletedToday: completed,
                onMarkComplete: () => _completeHabit(habit),
                onTap: () => _openDetails(habit),
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _MetricCard(label: 'Total Habits', value: summary.totalHabits.toString()),
      _MetricCard(label: 'Done Today', value: summary.completedToday.toString()),
      _MetricCard(
        label: 'Best Streak',
        value: '${summary.longestCurrentStreak} day(s)',
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final useGrid = constraints.maxWidth >= 560;
        if (useGrid) {
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 105,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, int index) => cards[index],
          );
        }

        return Column(
          children: cards
              .map((Widget card) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: card,
                  ))
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

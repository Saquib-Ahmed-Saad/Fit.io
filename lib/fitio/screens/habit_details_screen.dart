import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../repositories/habit_repository.dart';
import '../services/habit_metrics_service.dart';
import 'create_edit_habit_screen.dart';

class HabitDetailsScreen extends StatefulWidget {
  const HabitDetailsScreen({
    super.key,
    required this.repository,
    required this.habit,
  });

  final HabitRepository repository;
  final Habit habit;

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  final HabitMetricsService _metrics = HabitMetricsService();

  late Habit _habit;
  bool _loading = true;
  List<HabitLog> _logs = const <HabitLog>[];

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final id = _habit.id;
    if (id == null) {
      return;
    }
    final logs = await widget.repository.getLogsForHabit(id);
    if (!mounted) {
      return;
    }
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  Future<void> _markComplete() async {
    final id = _habit.id;
    if (id == null) {
      return;
    }
    await widget.repository.markHabitComplete(habitId: id, date: DateTime.now());
    await _loadLogs();
  }

  Future<void> _editHabit() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateEditHabitScreen(
          repository: widget.repository,
          habit: _habit,
        ),
      ),
    );

    if (updated != true || !mounted) {
      return;
    }

    final latest = await widget.repository.getHabits();
    final current = latest.where((Habit h) => h.id == _habit.id).firstOrNull;
    if (current != null) {
      setState(() {
        _habit = current;
      });
    }
    await _loadLogs();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteHabit() async {
    final id = _habit.id;
    if (id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: Text('Delete "${_habit.name}" and all completion history?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await widget.repository.deleteHabit(id);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final created = DateFormat('MMM d, y').format(_habit.createdDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit habit',
            onPressed: _editHabit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete habit',
            onPressed: _deleteHabit,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_habit.name, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(_habit.description.isEmpty ? 'No description provided.' : _habit.description),
                        const SizedBox(height: 8),
                        Text('Frequency: ${_habit.frequency}'),
                        Text('Created: $created'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _markComplete,
                          icon: const Icon(Icons.check),
                          label: const Text('Mark Complete Today'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _StatTile(
                            label: 'Current Streak',
                            value: '${_metrics.currentStreak(_logs)} day(s)',
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'Total Completions',
                            value: _logs.where((HabitLog l) => l.status).length.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Completion History', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (_logs.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No completion history yet.'),
                    ),
                  )
                else
                  ..._logs.map((HabitLog log) {
                    final date = DateFormat('EEE, MMM d').format(log.completionDate);
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          log.status ? Icons.check_circle : Icons.cancel,
                          color: log.status ? Colors.green : Colors.red,
                        ),
                        title: Text(date),
                        subtitle: Text(log.status ? 'Completed' : 'Incomplete'),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

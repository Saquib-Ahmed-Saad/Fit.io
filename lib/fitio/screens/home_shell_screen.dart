import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'create_edit_habit_screen.dart';
import 'dashboard_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _currentIndex = 0;

  Future<void> _openCreateHabit() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateEditHabitScreen(
          repository: widget.controller.habitRepository,
        ),
      ),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit created successfully.')),
      );
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardScreen(repository: widget.controller.habitRepository),
      ProgressScreen(repository: widget.controller.habitRepository),
      SettingsScreen(controller: widget.controller),
    ];

    final titles = <String>['Dashboard', 'Progress', 'Settings'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: screens[_currentIndex],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openCreateHabit,
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
        onDestinationSelected: (int idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
      ),
    );
  }
}

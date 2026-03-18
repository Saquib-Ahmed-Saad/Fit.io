import 'package:flutter/material.dart';

import '../app_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _resetting = false;

  Future<void> _resetData() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text('This deletes all habits and completion history.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (approved != true) {
      return;
    }

    setState(() {
      _resetting = true;
    });

    await widget.controller.habitRepository.clearAllData();

    if (!mounted) {
      return;
    }

    setState(() {
      _resetting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All app data has been reset.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: const Text('Use a darker color theme.'),
            value: widget.controller.darkMode,
            onChanged: widget.controller.setDarkMode,
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Store reminder preference locally.'),
            value: widget.controller.notificationsEnabled,
            onChanged: widget.controller.setNotificationsEnabled,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: const Text('Reset data'),
            subtitle: const Text('Delete all habits and logs from this device.'),
            trailing: _resetting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _resetting ? null : _resetData,
          ),
        ),
      ],
    );
  }
}

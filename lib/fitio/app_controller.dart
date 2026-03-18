import 'package:flutter/material.dart';

import 'repositories/habit_repository.dart';
import 'services/settings_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    HabitRepository? habitRepository,
    SettingsService? settingsService,
  })  : habitRepository = habitRepository ?? HabitRepository(),
        _settingsService = settingsService ?? SettingsService();

  final HabitRepository habitRepository;
  final SettingsService _settingsService;

  bool _darkMode = false;
  bool _notificationsEnabled = true;

  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> initialize() async {
    _darkMode = await _settingsService.loadDarkMode();
    _notificationsEnabled = await _settingsService.loadNotificationsEnabled();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await _settingsService.saveDarkMode(value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    await _settingsService.saveNotificationsEnabled(value);
  }
}

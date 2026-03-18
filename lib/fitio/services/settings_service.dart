import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String darkModeKey = 'dark_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(darkModeKey) ?? false;
  }

  Future<void> saveDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, enabled);
  }

  Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationsEnabledKey) ?? true;
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationsEnabledKey, enabled);
  }
}

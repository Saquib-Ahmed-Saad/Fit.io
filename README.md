# Fit.io

Fit.io is an offline-first habit tracker built with Flutter for Mobile App Development Project 1. It helps students create habits, track daily completion, maintain streaks, and review weekly progress without any cloud dependency.

## Team Members

- Saquib Ahmed: UI Design, Database Implementation, GitHub Management
- Bredon Huang: Navigation Flow, Testing, Documentation, Demo Video

## Features

- Splash screen with app branding and loading state
- Dashboard with personalized summary cards
- Create habit form with validation and frequency selector
- Habit details screen with completion history and streak metrics
- Edit and delete habit actions
- Daily completion tracking
- Weekly progress chart
- Progress statistics screen with habit performance summaries
- Settings screen with dark mode and notifications preference toggles
- Local data reset action with confirmation dialog

## Tech Stack

- Flutter (stable 3.x)
- Dart SDK ^3.10.7
- SQLite via `sqflite`
- `path_provider` and `path` for DB storage path
- `shared_preferences` for settings persistence
- `intl` for date formatting

## Local Data Storage

### SQLite Tables

`habits`
- `habit_id INTEGER PRIMARY KEY AUTOINCREMENT`
- `habit_name TEXT NOT NULL`
- `description TEXT NOT NULL`
- `frequency TEXT NOT NULL`
- `created_date TEXT NOT NULL`
- `is_archived INTEGER NOT NULL DEFAULT 0`

`habit_logs`
- `log_id INTEGER PRIMARY KEY AUTOINCREMENT`
- `habit_id INTEGER NOT NULL`
- `completion_date TEXT NOT NULL`
- `status INTEGER NOT NULL`
- `UNIQUE(habit_id, completion_date)` to avoid duplicate daily entries

### SharedPreferences Keys

- `dark_mode`
- `notifications_enabled`

## Setup Instructions

1. Clone the repository.
2. Open the project folder in VS Code.
3. Run dependencies:

```bash
flutter pub get
```

4. Run the app:

```bash
flutter run
```

## Build Release APK

```bash
flutter build apk --release
```

Output path:

`build/app/outputs/flutter-apk/app-release.apk`

## Usage Guide

1. Open the app and wait for the splash screen redirect.
2. On Dashboard, tap `Add Habit` to create your first habit.
3. Mark habits complete from the dashboard or details page.
4. Tap a habit to view history, streak, edit, or delete it.
5. Open `Progress` tab to view weekly chart and stats.
6. Open `Settings` tab for dark mode, notification preference, and reset.

## Accessibility and UX Notes

- Material 3 components for consistent design language
- Input validation and feedback snackbars
- Empty states for no-data scenarios
- Responsive summary layout for different screen widths
- Semantic labels via standard Material widgets and descriptive actions

## Testing and Quality

- Static analysis:

```bash
flutter analyze
```

- Test suite:

```bash
flutter test
```

Current status:
- `flutter analyze`: No issues found
- `flutter test`: All tests passed

## Folder Structure

```text
lib/
	fitio/
		app_controller.dart
		fitio_app.dart
		data/
		models/
		repositories/
		screens/
		services/
		widgets/
	main.dart
```

## Known Issues

- Notifications are preference-only in this version (no notification scheduling package added).

## Future Enhancements

- Local notification scheduling
- CSV/JSON export/import
- Search and filtering for habits
- Achievements and badge system

## License

This project is for academic course use.

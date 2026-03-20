# Fit.io

Fit.io is an offline-first habit tracker built with Flutter for Mobile App Development Project 1. It helps students create habits, track daily completion, maintain streaks, and review weekly progress without any cloud dependency.

## Team Members

| Name | Student ID | Role |

| Saquib Ahmed | 002742960 | UI Design, Database Implementation, GitHub Management |
| Brendon Huang | 002771859 | Navigation Flow, Testing, Documentation, Demo Video |

## Features

- Splash screen with app branding and animated loading state
- Dashboard with personalized summary cards and weekly bar chart
- Create habit form with name validation and frequency selector (Daily / Weekly / Custom)
- Habit details screen with completion history, streak counter, and edit/delete actions
- Mark habits complete directly from the dashboard or details screen
- Progress statistics screen with weekly chart and per-habit performance summaries
- Settings screen with dark mode toggle, notifications preference, and local data reset
- Fully offline — no internet connection required at any point

## Tech Stack

| Package | Version | Purpose |
| Flutter | stable 3.x | Cross-platform mobile framework |
| Dart SDK | ^3.10.7 | Language |
| sqflite | ^2.2.2 | Local SQLite database |
| path_provider | ^2.0.11 | Database file path resolution |
| path | ^1.8.2 | Path joining utilities |
| shared_preferences | ^2.5.3 | Settings key-value storage |
| intl | ^0.20.2 | Date formatting |
| sqflite_common_ffi | ^2.3.3 | SQLite for desktop unit tests (dev) |

## Local Data Storage

### SQLite Tables

`habits`

| Column | Type | Constraint | Notes |
| habit_id | INTEGER | PRIMARY KEY AUTOINCREMENT | |
| habit_name | TEXT | NOT NULL | |
| description | TEXT | NOT NULL | Empty string if omitted |
| frequency | TEXT | NOT NULL | 'Daily', 'Weekly', or 'Custom' |
| created_date | TEXT | NOT NULL | Stored as yyyy-MM-dd |
| is_archived | INTEGER | NOT NULL DEFAULT 0 | 0 = active, 1 = archived |

`habit_logs`

| Column | Type | Constraint | Notes |
| log_id | INTEGER | PRIMARY KEY AUTOINCREMENT | |
| habit_id | INTEGER | NOT NULL | Foreign key → habits.habit_id |
| completion_date | TEXT | NOT NULL | Stored as yyyy-MM-dd |
| status | INTEGER | NOT NULL | 1 = completed, 0 = incomplete |
| — | — | UNIQUE(habit_id, completion_date) | Prevents duplicate daily entries |
| — | — | ON DELETE CASCADE | Logs deleted with parent habit |

### SharedPreferences Keys

| Key | Type | Default | Description |
| dark_mode | bool | false | Light/dark theme preference |
| notifications_enabled | bool | true | Reminder notification preference |


## Setup Instructions

### Prerequisites

- Flutter SDK (stable channel, 3.x): [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter extension
- Android emulator or physical Android device

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/Saquib-Ahmed-Saad/Fit.io.git
cd Fit.io

# 2. Install dependencies
flutter pub get

# 3. Verify no issues
flutter analyze

# 4. Run in debug mode
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

Output path: `build/app/outputs/flutter-apk/app-release.apk`

---

## Usage Guide

1. Open the app — the splash screen loads and redirects to the Dashboard automatically.
2. On the Dashboard, tap **Add Habit** to create your first habit.
3. Fill in the habit name, optional description, and select a frequency.
4. Back on the Dashboard, tap **Complete** on any habit tile to mark it done for today.
5. Tap a habit name to open its detail screen — view streak, completion history, edit, or delete.
6. Open the **Progress** tab to see the weekly bar chart and per-habit performance stats.
7. Open the **Settings** tab to toggle dark mode, set notification preferences, or reset all data.

---

## Running Tests

```bash
# All tests
flutter test

# Unit tests only (no device needed — uses sqflite_common_ffi)
flutter test test/database_test.dart

# Widget tests
flutter test test/widget_test.dart

# Habit metrics service tests
flutter test test/habit_metrics_service_test.dart

# Integration tests (requires running emulator or device)
flutter test integration_test/app_test.dart

# Static analysis
flutter analyze
```

### Test Coverage

| File | Type | Author | Tests |
| test/database_test.dart | Unit | Brendon Huang | 20 tests — full CRUD coverage |
| test/widget_test.dart | Widget | Brendon Huang | WeeklyChart, HabitTile, CreateEditHabitScreen, SettingsScreen |
| test/habit_metrics_service_test.dart | Unit | Saquib Ahmed | Streak and weekly completion logic |
| integration_test/app_test.dart | Integration | Brendon Huang | 10 end-to-end flows |

---

## Folder Structure

```
Fit.io/
├── lib/
│   ├── main.dart                          # Entry point
│   └── fitio/
│       ├── app_controller.dart            # Global state (theme, notifications)
│       ├── fitio_app.dart                 # MaterialApp root with theme switching
│       ├── data/
│       │   └── fitio_database.dart        # SQLite singleton — schema + CRUD
│       ├── models/
│       │   ├── habit.dart                 # Habit data class
│       │   ├── habit_log.dart             # HabitLog data class
│       │   └── dashboard_summary.dart     # Summary view model
│       ├── repositories/
│       │   └── habit_repository.dart      # All DB operations accessed by screens
│       ├── screens/
│       │   ├── splash_screen.dart
│       │   ├── home_shell_screen.dart     # Bottom nav shell
│       │   ├── dashboard_screen.dart
│       │   ├── create_edit_habit_screen.dart
│       │   ├── habit_details_screen.dart
│       │   ├── progress_screen.dart
│       │   └── settings_screen.dart
│       ├── services/
│       │   ├── habit_metrics_service.dart # Streak and weekly stats logic
│       │   └── settings_service.dart      # SharedPreferences read/write
│       └── widgets/
│           ├── habit_tile.dart            # Reusable habit list item
│           └── weekly_chart.dart          # Animated 7-day bar chart
├── test/
│   ├── database_test.dart                 # 20 SQLite unit tests
│   ├── widget_test.dart                   # Widget rendering tests
│   └── habit_metrics_service_test.dart    # Metrics logic tests
├── integration_test/
│   └── app_test.dart                      # End-to-end app tests
├── test_driver/
│   └── integration_test.dart              # Integration test driver
├── android/                               # Android build configuration
├── ARCHITECTURE.md                        # Architectural decisions
└── pubspec.yaml                           # Dependencies
```

## Known Issues

- Notifications preference is stored locally but push notification delivery is not implemented (no scheduling package added in this version).
- Dark mode requires the app to reload the settings screen to reflect changes made outside the settings tab.

## Future Enhancements

- Local push notification scheduling via `flutter_local_notifications`
- CSV / JSON data export and import for backup and restore
- Search and filtering within the habit list
- Achievements and badge system for streak milestones
- Home screen widget for Android

---

## License

This project is for academic course use — Mobile App Development, GSU CRN #18267.

# Fit.io Architecture

## Overview

Fit.io follows a lightweight layered architecture to keep UI logic simple, data access isolated, and future scaling straightforward.

┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│   screens/  •  widgets/                         │
├─────────────────────────────────────────────────┤
│           Application Layer                     │
│   app_controller.dart  •  services/             │
├─────────────────────────────────────────────────┤
│           Data Layer                            │
│   repositories/  •  data/  •  models/           │
└─────────────────────────────────────────────────┘

Layers:
1. Presentation Layer (`screens/`, `widgets/`)
2. Application Layer (`app_controller.dart`, `services/`)
3. Data Layer (`repositories/`, `data/`, `models/`)


## Why This Architecture

- Separation of concerns: UI does not execute raw SQL. Screens call the repository; the repository calls the database.
- Maintainability: SQLite and SharedPreferences logic is centralized in one place each — easy to audit and change.
- Testability: Business calculations (streaks, weekly counts) live in `HabitMetricsService` and can be unit tested without a database or UI.
- Simplicity: Fits project scope and deadline without overengineering.


## Component Responsibilities

### Presentation Layer

| Component | Responsibility |
|-----------|---------------|
| `SplashScreen` | App branding and startup transition (1.5s delay then push to HomeShellScreen) |
| `HomeShellScreen` | Bottom NavigationBar shell — switches between Dashboard, Progress, Settings using AnimatedSwitcher |
| `DashboardScreen` | Habit list, summary cards, weekly chart, daily completion toggle |
| `CreateEditHabitScreen` | Form input, validation, create and update habit actions |
| `HabitDetailsScreen` | Single habit info, completion history list, streak, edit and delete |
| `ProgressScreen` | Weekly chart, total completions, per-habit performance |
| `SettingsScreen` | Dark mode, notifications preference, and reset data action |
| `HabitTile` | Reusable widget — habit name, frequency, complete button |
| `WeeklyChart` | Animated 7-bar chart built entirely with Flutter widgets (no external chart package) |

### Application Layer

| Component | Responsibility |
|-----------|---------------|
| `AppController` | `ChangeNotifier` — holds dark mode and notifications state, exposes `HabitRepository` to screens, persists settings via `SettingsService` |
| `SettingsService` | Reads and writes `dark_mode` and `notifications_enabled` keys in SharedPreferences |
| `HabitMetricsService` | Pure Dart logic — computes current streak and 7-day completion buckets from a list of `HabitLog` objects. No database calls. |

### Data Layer

| Component | Responsibility |
|-----------|---------------|
| `FitioDatabase` | Singleton SQLite database — creates schema on first launch, exposes all CRUD methods |
| `HabitRepository` | Thin layer over `FitioDatabase` — all screens interact with this, never with the database directly |
| `Habit` | Data class — maps to the `habits` table. Stores `createdDate` as `DateTime`, serialises to `yyyy-MM-dd` for SQLite |
| `HabitLog` | Data class — maps to the `habit_logs` table. Stores `completionDate` as `DateTime`, serialises to `yyyy-MM-dd` for SQLite |
| `DashboardSummary` | Read-only view model — aggregates total habits, completed today count, longest streak, and weekly bucket values for the dashboard |


## Navigation Architecture

### Pattern: Imperative stack with shell

main() → FitioApp → SplashScreen
                         │
                         └─ push replacement → HomeShellScreen
                                                      │
                              ┌───────────────────────┼────────────────────┐
                              │                       │                    │
                         DashboardScreen        ProgressScreen      SettingsScreen
                              │
                    ┌─────────┴──────────┐
                    │                    │
             HabitDetailsScreen   CreateEditHabitScreen
                    │
                    └── CreateEditHabitScreen (edit mode)
```

Why this pattern:

`HomeShellScreen` uses an `IndexedStack`-style approach with `AnimatedSwitcher` to switch between the three main tabs without rebuilding them. Deeper screens (Create, Edit, Details) are pushed on top via `Navigator.push` and return a `bool` result to tell the caller whether to reload data.

This keeps each screen self-contained — screens don't know about each other, they only know about their own repository calls.

Why not GoRouter or named routes:

The app has a simple hub-and-spoke structure with no deep links required. Adding a routing package would increase complexity without meaningful benefit for this project scope.

---

## Data Flow

User action (tap Complete)
        │
        ▼
Screen calls HabitRepository.markHabitComplete(habitId:, date:)
        │
        ▼
HabitRepository calls FitioDatabase.upsertLog(HabitLog)
        │
        ▼
FitioDatabase executes INSERT OR REPLACE into habit_logs
        │
        ▼
Screen calls repository.getAllLogs() to reload
        │
        ▼
HabitMetricsService.weeklyCompletions(logs) computes chart values
        │
        ▼
setState() triggers widget rebuild with new data


## Key Data Layer Decisions

### 1. DateTime vs String for date fields

Decision: `Habit.createdDate` and `HabitLog.completionDate` are stored as `DateTime` in Dart but serialised as `yyyy-MM-dd` strings in SQLite.

Why: Screens call `DateFormat('MMM d, y').format(habit.createdDate)` and `HabitMetricsService` performs date arithmetic (`day.difference(start).inDays`). Both operations require `DateTime`, not `String`. SQLite has no native date type, so `yyyy-MM-dd` is the standard text format — it sorts correctly alphabetically and parses reliably via `DateTime.parse()`.

Why not toIso8601String(): DateTime.now().toIso8601String() produces "2026-03-18T00:00:00.000". Storing this and then querying with a plain `"2026-03-18"` would never match. Using a consistent `yyyy-MM-dd` format for both storage and queries prevents this class of bug.

### 2. UNIQUE constraint on habit_logs

Decision: `UNIQUE(habit_id, completion_date)` is defined at the SQLite schema level.

Why: This is a database-enforced guarantee that no habit can have two log entries for the same day. Using `INSERT OR REPLACE` (via `ConflictAlgorithm.replace`) means marking complete and then unchecking simply replaces the row — no separate delete logic needed.

### 3. getDatabasesPath() instead of path_provider

Decision: `FitioDatabase` uses sqflite's own `getDatabasesPath()` rather than `getApplicationDocumentsDirectory()` from `path_provider`.

Why: `getApplicationDocumentsDirectory()` requires the Flutter engine's platform channel to be running. Unit tests using `sqflite_common_ffi` run on the Dart VM without the Flutter engine, so calling `path_provider` causes a "Binding has not been initialized" crash in tests. `getDatabasesPath()` is overridden by `sqflite_common_ffi` and works correctly in both environments.

### 4. Soft archive vs hard delete

Decision: Habits are soft-archived (`is_archived = 1`) when a user removes them through `archiveHabit()`. A `deleteHabit()` method also exists for permanent removal.

Why: Soft archive preserves log history for analytics even after a habit is removed from the active list. `getHabits()` filters with `WHERE is_archived = 0` so archived habits never appear in the UI.


## State Management Decision

This project uses local `StatefulWidget` state for per-screen data and a single `ChangeNotifier` (`AppController`) for global settings.

Rationale:
- Keeps undergraduate scope practical
- Avoids unnecessary complexity while still separating global state concerns
- Screens reload their own data in `initState()` and after navigation returns
- Supports clear evolution to Provider or Riverpod later if needed

## Testing Architecture

Three layers of tests — each serves a different purpose:

| Layer | File | Tool | What it proves |
|-------|------|------|----------------|
| Unit | `test/database_test.dart` | sqflite_common_ffi | SQLite CRUD operations work correctly in isolation — no UI, no device needed |
| Unit | `test/habit_metrics_service_test.dart` | flutter_test | Streak and weekly completion logic is correct independently of the database |
| Widget | `test/widget_test.dart` | flutter_test | Individual widgets render correctly and respond to interaction |
| Integration | `integration_test/app_test.dart` | integration_test | Full app flows work end-to-end on a real device or emulator |

Why `sqflite_common_ffi` for unit tests:
Standard `sqflite` requires the Android/iOS platform channel. `sqflite_common_ffi` replaces the database factory with an in-memory SQLite implementation that runs on the Dart VM — making CI and local desktop testing possible without an emulator.


## Offline-First Strategy

- All core business data is stored in SQLite on device
- Preferences are stored in SharedPreferences on device
- No network services are required for any core app functionality
- No Firebase, no REST APIs, no cloud storage of any kind

## Validation and Error Handling

- Form validation prevents empty habit name submissions (`Habit name is required.`)
- Confirmation dialogs protect destructive actions (delete habit, reset all data)
- Empty-state UI handles no habits and no logs scenarios gracefully
- Snackbars confirm successful create, update, and complete actions
- `!mounted` guards prevent setState calls after widget disposal


## Scalability Notes

Potential next steps that require minimal refactoring:

- Extract repository interfaces for proper dependency injection and mock testing
- Add use-case classes to encapsulate multi-step operations
- Add a notification scheduler service using `flutter_local_notifications`
- Add an export/import service for backup and restore workflows
- Migrate global state to Provider or Riverpod for more reactive UI updates

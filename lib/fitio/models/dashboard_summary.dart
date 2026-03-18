class DashboardSummary {
  const DashboardSummary({
    required this.totalHabits,
    required this.completedToday,
    required this.longestCurrentStreak,
    required this.weeklyCompletions,
  });

  final int totalHabits;
  final int completedToday;
  final int longestCurrentStreak;
  final List<int> weeklyCompletions;
}

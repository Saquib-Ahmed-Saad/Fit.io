class HabitLog {
  const HabitLog({
    this.id,
    required this.habitId,
    required this.completionDate,
    required this.status,
  });

  final int? id;
  final int habitId;
  final DateTime completionDate;
  final bool status;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'log_id': id,
      'habit_id': habitId,
      'completion_date': completionDate.toIso8601String(),
      'status': status ? 1 : 0,
    };
  }

  factory HabitLog.fromMap(Map<String, Object?> map) {
    return HabitLog(
      id: map['log_id'] as int?,
      habitId: map['habit_id'] as int? ?? 0,
      completionDate:
          DateTime.tryParse(map['completion_date'] as String? ?? '') ??
              DateTime.now(),
      status: (map['status'] as int? ?? 0) == 1,
    );
  }
}

/// One completion record for a habit on a specific date.
class HabitLog {
  final int? id;
  final int habitId;
  final DateTime completionDate;
  final bool status;

  const HabitLog({
    this.id,
    required this.habitId,
    required this.completionDate,
    this.status = true,
  });

  // Serialisation

  Map<String, dynamic> toMap() => {
        if (id != null) 'log_id': id,
        'habit_id': habitId,
        'completion_date': _fmt(completionDate), // store as yyyy-MM-dd
        'status': status ? 1 : 0,
      };

  factory HabitLog.fromMap(Map<String, dynamic> m) => HabitLog(
        id: m['log_id'] as int?,
        habitId: m['habit_id'] as int,
        completionDate: DateTime.parse(m['completion_date'] as String),
        status: (m['status'] as int? ?? 1) == 1,
      );

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  String toString() =>
      'HabitLog(id: $id, habitId: $habitId, '
      'date: ${_fmt(completionDate)}, status: $status)';
}

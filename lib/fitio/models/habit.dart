/// Represents a single user-defined habit.
class Habit {
  final int? id;
  final String name;
  final String description;
  final String frequency;
  final DateTime createdDate;
  final bool isArchived;

  const Habit({
    this.id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.createdDate,
    this.isArchived = false,
  });

  // Serialisation
  Map<String, dynamic> toMap() => {
        if (id != null) 'habit_id': id,
        'habit_name': name,
        'description': description,
        'frequency': frequency,
        'created_date': _fmt(createdDate), // store as yyyy-MM-dd
        'is_archived': isArchived ? 1 : 0,
      };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
        id: m['habit_id'] as int?,
        name: m['habit_name'] as String,
        description: m['description'] as String? ?? '',
        frequency: m['frequency'] as String? ?? 'Daily',
        createdDate: DateTime.parse(m['created_date'] as String),
        isArchived: (m['is_archived'] as int? ?? 0) == 1,
      );

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    String? frequency,
    DateTime? createdDate,
    bool? isArchived,
  }) =>
      Habit(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        frequency: frequency ?? this.frequency,
        createdDate: createdDate ?? this.createdDate,
        isArchived: isArchived ?? this.isArchived,
      );

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is Habit && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() =>
      'Habit(id: $id, name: $name, frequency: $frequency, archived: $isArchived)';
}

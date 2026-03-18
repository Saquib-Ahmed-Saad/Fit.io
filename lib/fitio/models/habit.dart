class Habit {
  const Habit({
    this.id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.createdDate,
    this.archived = false,
  });

  final int? id;
  final String name;
  final String description;
  final String frequency;
  final DateTime createdDate;
  final bool archived;

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    String? frequency,
    DateTime? createdDate,
    bool? archived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      createdDate: createdDate ?? this.createdDate,
      archived: archived ?? this.archived,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'habit_id': id,
      'habit_name': name,
      'description': description,
      'frequency': frequency,
      'created_date': createdDate.toIso8601String(),
      'is_archived': archived ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, Object?> map) {
    return Habit(
      id: map['habit_id'] as int?,
      name: map['habit_name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      frequency: map['frequency'] as String? ?? 'Daily',
      createdDate: DateTime.tryParse(map['created_date'] as String? ?? '') ??
          DateTime.now(),
      archived: (map['is_archived'] as int? ?? 0) == 1,
    );
  }
}

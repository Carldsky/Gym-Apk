class WorkoutSession {
  final String id;
  final DateTime date;
  final String split;
  final List<WorkoutExerciseRecord> exercises;

  const WorkoutSession({
    required this.id,
    required this.date,
    required this.split,
    required this.exercises,
  });

  int get completedExercises =>
      exercises.where((exercise) => exercise.done).length;

  int get totalExercises => exercises.length;

  int get completedSets => exercises
      .where((exercise) => exercise.done)
      .fold(0, (sum, exercise) => sum + exercise.sets);

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'split': split,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      split: json['split'] as String,
      exercises:
          (json['exercises'] as List)
              .map(
                (e) => WorkoutExerciseRecord.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
    );
  }
}

class WorkoutExerciseRecord {
  final String name;
  final double weight;
  final int sets;
  final int reps;
  final bool done;

  const WorkoutExerciseRecord({
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.done,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'weight': weight,
    'sets': sets,
    'reps': reps,
    'done': done,
  };

  factory WorkoutExerciseRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseRecord(
      name: json['name'] as String,
      weight: (json['weight'] as num).toDouble(),
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      done: json['done'] as bool,
    );
  }
}

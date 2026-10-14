const Map<String, String> defaultExerciseTargets = {
  // Chest
  'Incline Dumbbell Press': 'Upper Chest',
  'Barbell Bench Press': 'Middle Chest',
  'Decline Press': 'Lower Chest',
  'Dumbbell Bench Press': 'Middle Chest',
  'Incline Barbell Bench Press': 'Upper Chest',
  'Dumbbell Fly': 'Middle Chest',
  'Cable Crossover': 'Chest',
  'Chest Dip': 'Lower Chest',
  'Push Up': 'Chest',
  'Machine Chest Press': 'Chest',
  'Pec Deck Fly': 'Middle Chest',

  // Back
  'Lat Pulldown': 'Lats',
  'Seated Cable Row': 'Middle Back',
  'Face Pull': 'Rear Delts & Upper Back',
  'Back Extension': 'Lower Back',
  'Barbell Row': 'Middle Back',
  'T-Bar Row': 'Middle Back',
  'Pull Up': 'Lats',
  'Chin Up': 'Lats & Biceps',
  'Deadlift': 'Lower Back & Hamstrings',
  'Dumbbell Single Arm Row': 'Lats',

  // Shoulders
  'Shoulder Press': 'Front & Side Delts',
  'Dumbbell Lateral Raise': 'Side Delts',
  'Overhead Press': 'Front & Side Delts',
  'Military Press': 'Front Delts',
  'Arnold Press': 'Front & Side Delts',
  'Dumbbell Reverse Fly': 'Rear Delts',
  'Cable Lateral Raise': 'Side Delts',
  'Upright Row': 'Side Delts & Traps',
  'Shrugs': 'Traps',

  // Biceps
  'Dumbbell Biceps Curl': 'Biceps',
  'Hammer Curl': 'Biceps & Brachialis',
  'Barbell Curl': 'Biceps',
  'Preacher Curl': 'Biceps',
  'Concentration Curl': 'Biceps',
  'Incline Dumbbell Curl': 'Biceps',
  'Cable Biceps Curl': 'Biceps',

  // Triceps
  'Triceps Pushdown': 'Triceps',
  'Skull Crusher': 'Triceps',
  'Overhead Tricep Extension': 'Triceps',
  'Close Grip Bench Press': 'Triceps',
  'Triceps Kickback': 'Triceps',
  'Dips': 'Triceps & Chest',

  // Legs
  'Leg Press': 'Overall Leg Development',
  'Leg Curl': 'Quadriceps',
  'Lying Leg Curl': 'Hamstrings',
  'Barbell Squat': 'Quadriceps & Glutes',
  'Goblet Squat': 'Quadriceps',
  'Bulgarian Split Squat': 'Quadriceps & Glutes',
  'Romanian Deadlift': 'Hamstrings & Glutes',
  'Leg Extension': 'Quadriceps',
  'Calf Raise': 'Calves',
  'Walking Lunges': 'Quadriceps & Glutes',

  // Core
  'Core': 'Upper & Lower Abdominals',
  'Plank': 'Core',
  'Cable Crunch': 'Upper Abdominals',
  'Hanging Leg Raise': 'Lower Abdominals',
  'Russian Twist': 'Obliques',
  'Ab Wheel Rollout': 'Core',
};

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

  /// Mengelompokkan latihan dalam sesi yang sama berdasarkan nama dan target otot.
  List<GroupedWorkoutExercise> get groupedExercises {
    final Map<String, List<WorkoutExerciseRecord>> map = {};
    final Map<String, String> targetMap = {};

    for (final exercise in exercises) {
      final t = exercise.resolvedTarget;
      final key = '${exercise.name.trim().toLowerCase()}|||${t.toLowerCase()}';
      if (!map.containsKey(key)) {
        map[key] = [];
        targetMap[key] = t;
      }
      map[key]!.add(exercise);
    }

    return map.entries.map((entry) {
      final first = entry.value.first;
      return GroupedWorkoutExercise(
        name: first.name.trim(),
        target: targetMap[entry.key] ?? first.resolvedTarget,
        records: entry.value,
      );
    }).toList();
  }

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
  final String target;
  final double weight;
  final int sets;
  final int reps;
  final bool done;

  const WorkoutExerciseRecord({
    required this.name,
    this.target = '',
    required this.weight,
    required this.sets,
    required this.reps,
    required this.done,
  });

  String get resolvedTarget {
    if (target.trim().isNotEmpty) return target.trim();
    return defaultExerciseTargets[name.trim()] ?? 'Umum';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'target': target,
    'weight': weight,
    'sets': sets,
    'reps': reps,
    'done': done,
  };

  factory WorkoutExerciseRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseRecord(
      name: json['name'] as String,
      target: (json['target'] as String?) ?? '',
      weight: (json['weight'] as num).toDouble(),
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      done: json['done'] as bool,
    );
  }
}

class GroupedWorkoutExercise {
  final String name;
  final String target;
  final List<WorkoutExerciseRecord> records;

  const GroupedWorkoutExercise({
    required this.name,
    required this.target,
    required this.records,
  });

  int get totalSets => records.fold(0, (sum, r) => sum + r.sets);

  int get completedSets =>
      records.where((r) => r.done).fold(0, (sum, r) => sum + r.sets);

  int get totalVariations => records.length;

  int get completedVariations => records.where((r) => r.done).length;

  bool get isAllDone => records.isNotEmpty && records.every((r) => r.done);

  bool get hasAnyDone => records.any((r) => r.done);

  List<double> get distinctWeights {
    final list = records.map((r) => r.weight).toSet().toList()..sort();
    return list;
  }

  int get weightVariationsCount => distinctWeights.length;

  double get minWeight => distinctWeights.isEmpty ? 0 : distinctWeights.first;
  double get maxWeight => distinctWeights.isEmpty ? 0 : distinctWeights.last;
}

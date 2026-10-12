class Exercise {
  Exercise({
    required this.name,
    required this.target,
    required this.sets,
    required this.reps,
    this.weight = 0,
    this.done = false,
  });

  final String name;
  final String target;
  int sets;
  int reps;
  double weight;
  bool done;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target': target,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'done': done,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      target: json['target'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      done: json['done'] as bool? ?? false,
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';

class WorkoutProvider extends ChangeNotifier {
  static const String _storageKey = 'workout_data_v1';
  static const String _dateKey = 'last_workout_date';

  String selectedSplit = 'Push Day';
  bool isLoaded = false;

  final Map<String, List<Exercise>> workouts = {
    'Push Day': [
      Exercise(
        name: 'Incline Dumbbell Press',
        target: 'Upper Chest',
        sets: 3,
        reps: 12,
        weight: 10,
      ),
      Exercise(
        name: 'Barbell Bench Press',
        target: 'Middle Chest',
        sets: 3,
        reps: 10,
        weight: 20,
      ),
      Exercise(
        name: 'Decline Press',
        target: 'Lower Chest',
        sets: 3,
        reps: 12,
        weight: 15,
      ),
      Exercise(
        name: 'Shoulder Press',
        target: 'Front & Side Delts',
        sets: 3,
        reps: 12,
        weight: 8,
      ),
      Exercise(
        name: 'Dumbbell Lateral Raise',
        target: 'Side Delts',
        sets: 3,
        reps: 12,
        weight: 5,
      ),
      Exercise(
        name: 'Triceps Pushdown',
        target: 'Triceps',
        sets: 3,
        reps: 12,
        weight: 15,
      ),
    ],
    'Pull Day': [
      // Back - Lebar punggung
      Exercise(
        name: 'Lat Pulldown',
        target: 'Lats',
        sets: 3,
        reps: 12,
        weight: 25,
      ),

      // Back - Ketebalan punggung
      Exercise(
        name: 'Seated Cable Row',
        target: 'Middle Back',
        sets: 3,
        reps: 12,
        weight: 20,
      ),

      // Back - Punggung atas
      Exercise(
        name: 'Face Pull',
        target: 'Rear Delts & Upper Back',
        sets: 3,
        reps: 12,
        weight: 10,
      ),

      // Back - Punggung bawah
      Exercise(
        name: 'Back Extension',
        target: 'Lower Back',
        sets: 3,
        reps: 12,
        weight: 0,
      ),

      // Biceps - Gerakan utama
      Exercise(
        name: 'Dumbbell Biceps Curl',
        target: 'Biceps',
        sets: 3,
        reps: 12,
        weight: 8,
      ),

      // Biceps - Fokus brachialis dan lengan bawah
      Exercise(
        name: 'Hammer Curl',
        target: 'Biceps & Brachialis',
        sets: 3,
        reps: 12,
        weight: 6,
      ),

      Exercise(
        name: 'Dumbbell Reverse Fly',
        target: 'Rear Delts',
        sets: 3,
        reps: 12,
        weight: 4,
      ),
    ],
    'Leg Day': [
      Exercise(
        name: 'Leg Press',
        target: 'Overall Leg Development',
        sets: 3,
        reps: 12,
        weight: 40,
      ),
      Exercise(
        name: 'Leg Curl',
        target: 'Quadriceps',
        sets: 3,
        reps: 15,
        weight: 15,
      ),
      Exercise(
        name: 'Lying Leg Curl',
        target: 'back of the thigh',
        sets: 3,
        reps: 15,
        weight: 15,
      ),
      Exercise(
        name: 'Core',
        target: 'Upper & Lower Abdominals',
        sets: 3,
        reps: 12,
        weight: 0,
      ),
    ],
    'Upper Body': [
      Exercise(
        name: 'Bench Press',
        target: 'Chest',
        sets: 3,
        reps: 10,
        weight: 20,
      ),
      Exercise(
        name: 'Lat Pulldown',
        target: 'Back',
        sets: 3,
        reps: 12,
        weight: 25,
      ),
      Exercise(
        name: 'Shoulder Press',
        target: 'Shoulders',
        sets: 3,
        reps: 12,
        weight: 8,
      ),
      Exercise(
        name: 'Dumbbell Curl',
        target: 'Biceps',
        sets: 3,
        reps: 12,
        weight: 8,
      ),
    ],
  };

  WorkoutProvider() {
    loadData();
  }

  List<Exercise> get exercises => workouts[selectedSplit] ?? [];

  int get completedExercises =>
      exercises.where((exercise) => exercise.done).length;

  Exercise? get bestPerformanceExercise {
    if (exercises.isEmpty) return null;

    Exercise best = exercises.first;

    for (final exercise in exercises) {
      if (exercise.weight > best.weight) {
        best = exercise;
      }
    }

    return best;
  }

  double get bestPerformanceKg => bestPerformanceExercise?.weight ?? 0;

  // Format tanggal lokal: YYYY-MM-DD.
  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '${now.year}-$month-$day';
  }

  // Mengosongkan checklist semua split tanpa mengubah
  // nama latihan, set, repetisi, dan beban.
  void _resetAllChecklists() {
    for (final exerciseList in workouts.values) {
      for (final exercise in exerciseList) {
        exercise.done = false;
      }
    }
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);
      final lastDate = prefs.getString(_dateKey);
      final today = _todayKey();

      if (savedData != null) {
        final data = jsonDecode(savedData) as Map<String, dynamic>;

        final savedWorkouts = data['workouts'];

        if (savedWorkouts is Map<String, dynamic>) {
          workouts.clear();
          for (final splitEntry in savedWorkouts.entries) {
            final split = splitEntry.key;
            final savedExercises = splitEntry.value;

            if (savedExercises is! List) {
              continue;
            }

            workouts[split] = savedExercises
                .whereType<Map<String, dynamic>>()
                .map((item) => Exercise.fromJson(item))
                .toList();
          }
        }

        final savedSplit = data['selectedSplit'] as String?;

        if (savedSplit != null && workouts.containsKey(savedSplit)) {
          selectedSplit = savedSplit;
        } else if (workouts.isNotEmpty) {
          selectedSplit = workouts.keys.first;
        } else {
          selectedSplit = '';
        }
      }

      // Jika tanggal berubah, reset checklist.
      if (lastDate != today) {
        _resetAllChecklists();
      }

      // Simpan tanggal hari ini dan data checklist terbaru.
      await prefs.setString(_dateKey, today);
      await saveData();
    } catch (error) {
      debugPrint('Gagal memuat data latihan: $error');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = {
        'selectedSplit': selectedSplit,
        'workouts': workouts.map(
          (split, exercises) => MapEntry(
            split,
            exercises.map((exercise) => exercise.toJson()).toList(),
          ),
        ),
      };

      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (error) {
      debugPrint('Gagal menyimpan data latihan: $error');
    }
  }

  void selectSplit(String split) {
    if (!workouts.containsKey(split)) return;

    selectedSplit = split;
    notifyListeners();
    saveData();
  }

  void toggleDone(Exercise exercise) {
    exercise.done = !exercise.done;
    notifyListeners();
    saveData();
  }

  void updateExercise(
    Exercise exercise, {
    required int sets,
    required int reps,
    required double weight,
  }) {
    if (sets <= 0 || reps <= 0 || weight < 0) return;

    exercise.sets = sets;
    exercise.reps = reps;
    exercise.weight = weight;

    notifyListeners();
    saveData();
  }

  void addExercise(
    Exercise exercise, {
    String? split,
  }) {
    final targetSplit = split ?? selectedSplit;
    if (!workouts.containsKey(targetSplit)) {
      workouts[targetSplit] = [];
    }
    workouts[targetSplit]!.add(exercise);
    notifyListeners();
    saveData();
  }

  void removeExercise(
    Exercise exercise, {
    String? split,
  }) {
    final targetSplit = split ?? selectedSplit;
    if (workouts.containsKey(targetSplit)) {
      workouts[targetSplit]!.remove(exercise);
      notifyListeners();
      saveData();
    }
  }

  void removeExerciseAt(
    int index, {
    String? split,
  }) {
    final targetSplit = split ?? selectedSplit;
    if (workouts.containsKey(targetSplit)) {
      final list = workouts[targetSplit]!;
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
        notifyListeners();
        saveData();
      }
    }
  }

  bool addSplit(String splitName) {
    final name = splitName.trim();
    if (name.isEmpty || workouts.containsKey(name)) return false;

    workouts[name] = [];
    selectedSplit = name;
    notifyListeners();
    saveData();
    return true;
  }

  bool deleteSplit(String splitName) {
    if (!workouts.containsKey(splitName)) return false;

    workouts.remove(splitName);
    if (selectedSplit == splitName) {
      selectedSplit = workouts.keys.isNotEmpty ? workouts.keys.first : '';
    }
    notifyListeners();
    saveData();
    return true;
  }

  bool renameSplit(String oldName, String newName) {
    final target = newName.trim();
    if (target.isEmpty ||
        !workouts.containsKey(oldName) ||
        workouts.containsKey(target)) {
      return false;
    }
    final currentExercises = workouts.remove(oldName) ?? [];
    workouts[target] = currentExercises;
    if (selectedSplit == oldName) {
      selectedSplit = target;
    }
    notifyListeners();
    saveData();
    return true;
  }
}

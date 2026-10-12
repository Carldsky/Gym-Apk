import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_session.dart';
import 'workout_provider.dart';

class ProgressHistoryProvider extends ChangeNotifier {
  static const String _storageKey = 'workout_history_v1';

  List<WorkoutSession> _sessions = [];
  bool _isLoaded = false;

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoaded => _isLoaded;

  Future<void> loadHistory() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List;

        _sessions =
            decoded
                .map(
                  (item) => WorkoutSession.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList();

        _sessions.sort((a, b) => b.date.compareTo(a.date));
      } catch (_) {
        // Data yang tidak valid tidak akan dipakai.
        _sessions = [];
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(_sessions.map((session) => session.toJson()).toList()),
    );
  }

  /// Simpan snapshot latihan dari WorkoutProvider.
  Future<void> recordWorkout(WorkoutProvider workout) async {
    if (!_isLoaded) {
      await loadHistory();
    }

    if (workout.exercises.isEmpty) return;

    final now = DateTime.now();

    final records =
        workout.exercises.map((exercise) {
          return WorkoutExerciseRecord(
            name: exercise.name,
            weight: exercise.weight,
            sets: exercise.sets,
            reps: exercise.reps,
            done: exercise.done,
          );
        }).toList();

    final session = WorkoutSession(
      id: now.microsecondsSinceEpoch.toString(),
      date: now,
      split: workout.selectedSplit,
      exercises: records,
    );

    _sessions.insert(0, session);

    await _saveHistory();
    notifyListeners();
  }

  /// Total sesi latihan pada hari tertentu.
  int sessionsOn(DateTime day) {
    return _sessions.where((session) {
      return session.date.year == day.year &&
          session.date.month == day.month &&
          session.date.day == day.day;
    }).length;
  }

  /// Jumlah sesi dari Senin sampai Minggu minggu ini.
  List<int> get weeklySessions {
    final today = DateTime.now();
    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));

    return List.generate(7, (index) {
      return sessionsOn(monday.add(Duration(days: index)));
    });
  }

  /// Daftar nama latihan yang pernah tersimpan.
  List<String> get exerciseNames {
    final names = <String>{};

    for (final session in _sessions) {
      for (final exercise in session.exercises) {
        names.add(exercise.name);
      }
    }

    return names.toList()..sort();
  }

  /// Rekor beban tertinggi setiap latihan.
  Map<String, double> get personalRecords {
    final records = <String, double>{};

    for (final session in _sessions) {
      for (final exercise in session.exercises) {
        if (!exercise.done) continue;

        final previous = records[exercise.name] ?? 0;

        if (exercise.weight > previous) {
          records[exercise.name] = exercise.weight;
        }
      }
    }

    return records;
  }

  /// Data perkembangan beban dari sesi yang tercatat.
  List<WorkoutExerciseRecord> loadProgress(String exerciseName) {
    final result = <WorkoutExerciseRecord>[];

    final sortedSessions = [..._sessions]
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final session in sortedSessions) {
      for (final exercise in session.exercises) {
        if (exercise.name == exerciseName && exercise.done) {
          result.add(exercise);
        }
      }
    }

    return result;
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((session) => session.id == sessionId);
    await _saveHistory();
    notifyListeners();
  }
}

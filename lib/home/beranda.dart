import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/workout_provider.dart';
import '../providers/profile_provider.dart';

const Color backgroundColor = Color(0xFF0B0F12);
const Color cardColor = Color(0xFF151B20);
const Color accentColor = Color(0xFF62E6A2);
const Color secondaryTextColor = Color(0xFF9AA5AE);

String formatWeight(double weight) {
  return weight == weight.roundToDouble()
      ? weight.toInt().toString()
      : weight.toStringAsFixed(1);
}

String getGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 11) return 'Selamat pagi';
  if (hour < 15) return 'Selamat siang';
  if (hour < 18) return 'Selamat sore';
  return 'Selamat malam';
}

String getFullDate() {
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final now = DateTime.now();

  return '${days[now.weekday - 1]}, '
      '${now.day} ${months[now.month - 1]} ${now.year}';
}

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final bestExercise = provider.bestPerformanceExercise;
        final profile = context.watch<ProfileProvider>();

        final displayName =
            profile.name.trim().isEmpty ? 'Member' : profile.name.trim();

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${getGreeting()},',
                    style: const TextStyle(
                      color: secondaryTextColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$displayName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Let’s get stronger!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getFullDate(),
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // SPLIT SELECTOR
                  const Text(
                    'Workout Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 43,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          provider.workouts.keys.map((split) {
                            final isSelected = provider.selectedSplit == split;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(split),
                                selected: isSelected,
                                onSelected: (_) {
                                  provider.selectSplit(split);
                                },
                                selectedColor: accentColor,
                                backgroundColor: cardColor,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected
                                          ? backgroundColor
                                          : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                side: BorderSide(
                                  color:
                                      isSelected ? accentColor : Colors.white12,
                                ),
                                showCheckmark: false,
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BEST PERFORMANCE CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF183D2D), Color(0xFF151B20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.emoji_events_outlined,
                            color: accentColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Best Performance',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                bestExercise == null
                                    ? '0 kg'
                                    : '${formatWeight(bestExercise.weight)} kg',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                bestExercise?.name ?? 'Belum ada latihan',
                                style: const TextStyle(
                                  color: accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Beban tertinggi • ${provider.selectedSplit}',
                                style: const TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // PROGRESS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Exercises',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${provider.completedExercises}/${provider.exercises.length} selesai',
                        style: const TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value:
                          provider.exercises.isEmpty
                              ? 0
                              : provider.completedExercises /
                                  provider.exercises.length,
                      minHeight: 7,
                      backgroundColor: cardColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        accentColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // EXERCISE LIST
                  ...provider.exercises.map((exercise) {
                    return _ExerciseCard(
                      exercise: exercise,
                      onToggle: () => provider.toggleDone(exercise),
                      onEdit: () => _editExercise(context, provider, exercise),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _editExercise(
    BuildContext context,
    WorkoutProvider provider,
    Exercise exercise,
  ) {
    final setsController = TextEditingController(
      text: exercise.sets.toString(),
    );
    final repsController = TextEditingController(
      text: exercise.reps.toString(),
    );
    final weightController = TextEditingController(
      text: formatWeight(exercise.weight),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            'Edit ${exercise.name}',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _numberField(setsController, 'Sets'),
                const SizedBox(height: 12),
                _numberField(repsController, 'Reps'),
                const SizedBox(height: 12),
                _numberField(weightController, 'Berat (kg)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: backgroundColor,
              ),
              onPressed: () {
                final sets = int.tryParse(setsController.text);
                final reps = int.tryParse(repsController.text);
                final weight = double.tryParse(
                  weightController.text.replaceAll(',', '.'),
                );

                if (sets == null ||
                    reps == null ||
                    weight == null ||
                    sets <= 0 ||
                    reps <= 0 ||
                    weight < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan nilai yang valid.')),
                  );
                  return;
                }

                provider.updateExercise(
                  exercise,
                  sets: sets,
                  reps: reps,
                  weight: weight,
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: secondaryTextColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onToggle,
    required this.onEdit,
  });

  final Exercise exercise;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color:
              exercise.done
                  ? accentColor.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: exercise.done,
            onChanged: (_) => onToggle(),
            activeColor: accentColor,
            checkColor: backgroundColor,
            side: const BorderSide(color: secondaryTextColor),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    color: exercise.done ? secondaryTextColor : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration:
                        exercise.done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  exercise.target,
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _detailChip(
                      Icons.fitness_center,
                      '${formatWeight(exercise.weight)} kg',
                    ),
                    _detailChip(Icons.repeat, '${exercise.sets} sets'),
                    _detailChip(Icons.refresh, '${exercise.reps} reps'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: accentColor, size: 20),
            tooltip: 'Edit latihan',
          ),
        ],
      ),
    );
  }

  Widget _detailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

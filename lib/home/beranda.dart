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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Workout Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          if (provider.workouts.isNotEmpty &&
                              provider.selectedSplit.isNotEmpty)
                            IconButton(
                              onPressed:
                                  () => _confirmDeleteSplit(
                                    context,
                                    provider,
                                    provider.selectedSplit,
                                  ),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              tooltip: 'Hapus split ${provider.selectedSplit}',
                              visualDensity: VisualDensity.compact,
                            ),
                          InkWell(
                            onTap: () => _showAddSplitDialog(context, provider),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: accentColor, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tambah Split',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 43,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...provider.workouts.keys.map((split) {
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
                        }),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: const Icon(
                              Icons.add,
                              color: accentColor,
                              size: 16,
                            ),
                            label: const Text('Split Baru'),
                            backgroundColor: cardColor,
                            labelStyle: const TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: accentColor.withValues(alpha: 0.4),
                            ),
                            onPressed:
                                () => _showAddSplitDialog(context, provider),
                          ),
                        ),
                      ],
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
                                'Beban tertinggi • ${provider.selectedSplit.isEmpty ? "Belum ada split" : provider.selectedSplit}',
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
                      Row(
                        children: [
                          Text(
                            '${provider.completedExercises}/${provider.exercises.length} selesai',
                            style: const TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _addExercise(context, provider),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: accentColor, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tambah',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                  if (provider.exercises.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 28,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fitness_center_outlined,
                            color: secondaryTextColor,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            provider.selectedSplit.isEmpty
                                ? 'Belum ada split latihan yang dipilih'
                                : 'Belum ada latihan di ${provider.selectedSplit}',
                            style: const TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (provider.selectedSplit.isEmpty) {
                                _showAddSplitDialog(context, provider);
                              } else {
                                _addExercise(context, provider);
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              provider.selectedSplit.isEmpty
                                  ? 'Tambah Split'
                                  : 'Tambah Latihan',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: backgroundColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...provider.exercises.map((exercise) {
                      return _ExerciseCard(
                        exercise: exercise,
                        onToggle: () => provider.toggleDone(exercise),
                        onEdit: () => _editExercise(context, provider, exercise),
                        onDelete:
                            () => _confirmDeleteExercise(
                              context,
                              provider,
                              exercise,
                            ),
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

  void _addExercise(
    BuildContext context,
    WorkoutProvider provider,
  ) {
    if (provider.selectedSplit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan buat atau pilih workout split terlebih dahulu.'),
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '12');
    final weightController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            'Tambah Latihan (${provider.selectedSplit})',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(nameController, 'Nama Latihan (misal: Incline Dumbbell Press)'),
                const SizedBox(height: 12),
                _textField(targetController, 'Target Otot (misal: Upper Chest)'),
                const SizedBox(height: 12),
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
                final name = nameController.text.trim();
                final target = targetController.text.trim();
                final sets = int.tryParse(setsController.text);
                final reps = int.tryParse(repsController.text);
                final weight = double.tryParse(
                  weightController.text.replaceAll(',', '.'),
                );

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama latihan tidak boleh kosong.')),
                  );
                  return;
                }

                if (sets == null ||
                    reps == null ||
                    weight == null ||
                    sets <= 0 ||
                    reps <= 0 ||
                    weight < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan nilai sets, reps, dan berat yang valid.')),
                  );
                  return;
                }

                provider.addExercise(
                  Exercise(
                    name: name,
                    target: target.isEmpty ? 'Umum' : target,
                    sets: sets,
                    reps: reps,
                    weight: weight,
                  ),
                );

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name berhasil ditambahkan ke ${provider.selectedSplit}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteExercise(
    BuildContext context,
    WorkoutProvider provider,
    Exercise exercise,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            'Hapus Latihan',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${exercise.name}" dari ${provider.selectedSplit}?',
            style: const TextStyle(color: secondaryTextColor),
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
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                provider.removeExercise(exercise);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${exercise.name} telah dihapus'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSplitDialog(BuildContext context, WorkoutProvider provider) {
    final splitController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            'Tambah Workout Split',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan nama split latihan baru (misal: Arms Day, Chest & Tri, dll.)',
                style: TextStyle(color: secondaryTextColor, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _textField(splitController, 'Nama Split (misal: Arms Day)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: secondaryTextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: backgroundColor,
              ),
              onPressed: () {
                final splitName = splitController.text.trim();
                if (splitName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama split tidak boleh kosong.')),
                  );
                  return;
                }

                if (provider.workouts.containsKey(splitName)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Split "$splitName" sudah ada.')),
                  );
                  return;
                }

                provider.addSplit(splitName);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Split "$splitName" berhasil ditambahkan!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSplit(
    BuildContext context,
    WorkoutProvider provider,
    String split,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            'Hapus Workout Split',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus split "$split" beserta seluruh latihan di dalamnya?',
            style: const TextStyle(color: secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: secondaryTextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                provider.deleteSplit(split);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Split "$split" berhasil dihapus'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
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
    required this.onDelete,
  });

  final Exercise exercise;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            tooltip: 'Hapus latihan',
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

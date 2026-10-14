import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout_session.dart';
import '../providers/progress_history_provider.dart';

String formatWeightNumber(double weight) {
  return weight == weight.roundToDouble()
      ? weight.toInt().toString()
      : weight.toStringAsFixed(1);
}

String formatSessionDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}

/// riwayat latihan
class WorkoutHistoryView extends StatelessWidget {
  final bool showSectionTitle;

  const WorkoutHistoryView({
    super.key,
    this.showSectionTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final history = context.watch<ProgressHistoryProvider>();
    final sessions = history.sessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSectionTitle) ...[
          const Text(
            'Riwayat Latihan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF151B20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.history_toggle_off,
                  color: Color(0xFF9AA5AE),
                  size: 38,
                ),
                SizedBox(height: 10),
                Text(
                  'Belum ada riwayat latihan.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Selesaikan latihan dan simpan sesi untuk mencatat riwayat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9AA5AE), fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...sessions.map((session) => _WorkoutSessionCard(session: session)),
      ],
    );
  }
}

class _WorkoutSessionCard extends StatelessWidget {
  final WorkoutSession session;

  const _WorkoutSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final groupedList = session.groupedExercises;
    final totalCompleted =
        session.exercises.where((exercise) => exercise.done).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFF151B20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: totalCompleted > 0
              ? Color(0xFF62E6A2).withValues(alpha: 0.15)
              : Colors.white10,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          iconColor: Color(0xFF62E6A2),
          collapsedIconColor: Color(0xFF9AA5AE),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  session.split.isEmpty ? 'Workout Session' : session.split,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF62E6A2).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Color(0xFF62E6A2).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${groupedList.length} Latihan',
                  style: const TextStyle(
                    color: Color(0xFF62E6A2),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 13,
                  color: Color(0xFF9AA5AE),
                ),
                const SizedBox(width: 4),
                Text(
                  formatSessionDate(session.date),
                  style: const TextStyle(color: Color(0xFF9AA5AE), fontSize: 12),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Color(0xFF9AA5AE))),
                const SizedBox(width: 8),
                Text(
                  '$totalCompleted/${session.totalExercises} selesai',
                  style: TextStyle(
                    color: totalCompleted > 0 ? Color(0xFF62E6A2) : Color(0xFF9AA5AE),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 10),
                  if (groupedList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Tidak ada latihan yang tercatat dalam sesi ini.',
                        style: TextStyle(color: Color(0xFF9AA5AE), fontSize: 13),
                      ),
                    )
                  else
                    ...groupedList.map(
                      (group) => _GroupedExerciseCard(
                        group: group,
                        sessionSplit: session.split,
                        sessionDate: session.date,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total ${session.completedSets} set berhasil dilakukan',
                        style: const TextStyle(
                          color: Color(0xFF9AA5AE),
                          fontSize: 11,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _confirmDelete(context, session.id),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text(
                          'Hapus sesi',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Color(0xFF151B20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Riwayat Sesi?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Sesi latihan ini akan dihapus permanen dari riwayat kamu.',
          style: TextStyle(color: Color(0xFF9AA5AE)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF9AA5AE)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await context
                  .read<ProgressHistoryProvider>()
                  .deleteSession(sessionId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Riwayat sesi berhasil dihapus.'),
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

/// Riwayat card berserta detail nya.
class _GroupedExerciseCard extends StatefulWidget {
  final GroupedWorkoutExercise group;
  final String sessionSplit;
  final DateTime sessionDate;

  const _GroupedExerciseCard({
    required this.group,
    required this.sessionSplit,
    required this.sessionDate,
  });

  @override
  State<_GroupedExerciseCard> createState() => _GroupedExerciseCardState();
}

class _GroupedExerciseCardState extends State<_GroupedExerciseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final distinctWeights = group.distinctWeights;

    String weightSummaryText;
    if (distinctWeights.isEmpty) {
      weightSummaryText = '0 kg';
    } else if (distinctWeights.length == 1) {
      weightSummaryText = '${formatWeightNumber(distinctWeights.first)} kg';
    } else {
      weightSummaryText =
          '${formatWeightNumber(group.minWeight)} - ${formatWeightNumber(group.maxWeight)} kg';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1B232A),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _isExpanded
              ? Color(0xFF62E6A2).withValues(alpha: 0.4)
              : group.isAllDone
                  ? Color(0xFF62E6A2).withValues(alpha: 0.2)
                  : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          // Header Card
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(13),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  // Icon status penyelasaian
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: group.isAllDone
                          ? Color(0xFF62E6A2).withValues(alpha: 0.15)
                          : group.hasAnyDone
                              ? Colors.amber.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      group.isAllDone
                          ? Icons.check_circle
                          : group.hasAnyDone
                              ? Icons.timelapse
                              : Icons.fitness_center,
                      size: 18,
                      color: group.isAllDone
                          ? Color(0xFF62E6A2)
                          : group.hasAnyDone
                              ? Colors.amber
                              : Color(0xFF9AA5AE),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Info Latihan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: group.isAllDone
                                ? null
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // Target Otot Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF0B0F12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                group.target.isEmpty ? 'Umum' : group.target,
                                style: const TextStyle(
                                  color: Color(0xFF9AA5AE),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Total Set Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF62E6A2).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${group.totalSets} Set',
                                style: const TextStyle(
                                  color: Color(0xFF62E6A2),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Variasi Beban Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${group.weightVariationsCount} Variasi Beban',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Ringkasan Beban
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        weightSummaryText,
                        style: const TextStyle(
                          color: Color(0xFF62E6A2),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? 'Tutup' : 'Detail',
                            style: TextStyle(
                              color: _isExpanded ? Color(0xFF62E6A2) : Color(0xFF9AA5AE),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: _isExpanded ? Color(0xFF62E6A2) : Color(0xFF9AA5AE),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Detail seluruh set, reps, beban, dan status penyelesaiannya saat diklik
          if (_isExpanded) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: Color(0xFF0B0F12).withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(13),
                  bottomRight: Radius.circular(13),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DETAIL SET & VARIASI BEBAN',
                        style: TextStyle(
                          color: Color(0xFF9AA5AE),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),
                      InkWell(
                        onTap: () => _openDetailBottomSheet(context),
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.open_in_full,
                                size: 12,
                                color: Color(0xFF62E6A2),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Mode Penuh',
                                style: TextStyle(
                                  color: Color(0xFF62E6A2),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Daftar setiap variasi beban / set record
                  ...widget.group.records.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final record = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF151B20),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: record.done
                              ? Color(0xFF62E6A2).withValues(alpha: 0.25)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Index variasi
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: record.done
                                  ? Color(0xFF62E6A2).withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#$index',
                              style: TextStyle(
                                color: record.done
                                    ? Color(0xFF62E6A2)
                                    : Color(0xFF9AA5AE),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Beban Highlight
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${formatWeightNumber(record.weight)} kg',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${record.sets} Set × ${record.reps} Reps',
                                      style: const TextStyle(
                                        color: Color(0xFF9AA5AE),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status Penyelesaian
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: record.done
                                  ? Color(0xFF62E6A2).withValues(alpha: 0.15)
                                  : Colors.redAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: record.done
                                    ? Color(0xFF62E6A2).withValues(alpha: 0.4)
                                    : Colors.redAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  record.done
                                      ? Icons.check
                                      : Icons.close,
                                  size: 12,
                                  color: record.done
                                      ? Color(0xFF62E6A2)
                                      : Colors.redAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  record.done ? 'Selesai' : 'Belum',
                                  style: TextStyle(
                                    color: record.done
                                        ? Color(0xFF62E6A2)
                                        : Colors.redAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF151B20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (modalContext) {
        final group = widget.group;

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Modal Handle
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),

                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF62E6A2).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF62E6A2),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Target: ${group.target} • Sesi: ${widget.sessionSplit}',
                              style: const TextStyle(
                                color: Color(0xFF9AA5AE),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalContext),
                        icon: const Icon(Icons.close, color: Color(0xFF9AA5AE)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white10, height: 1),

                // Summary Stats
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: _statPill(
                          'Total Set',
                          '${group.totalSets}',
                          Icons.repeat,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statPill(
                          'Variasi Beban',
                          '${group.weightVariationsCount}',
                          Icons.scale_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statPill(
                          'Selesai',
                          '${group.completedVariations}/${group.totalVariations}',
                          Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ),

                // List Variasi
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                    itemCount: group.records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final record = group.records[index];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Color(0xFF1B232A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: record.done
                                ? Color(0xFF62E6A2).withValues(alpha: 0.3)
                                : Colors.white10,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: record.done
                                    ? Color(0xFF62E6A2).withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  color: record.done
                                      ? Color(0xFF62E6A2)
                                      : Color(0xFF9AA5AE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${formatWeightNumber(record.weight)} kg',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${record.sets} Set × ${record.reps} Reps',
                                    style: const TextStyle(
                                      color: Color(0xFF9AA5AE),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: record.done
                                    ? Color(0xFF62E6A2).withValues(alpha: 0.15)
                                    : Colors.redAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: record.done
                                      ? Color(0xFF62E6A2).withValues(alpha: 0.35)
                                      : Colors.redAccent.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    record.done
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 14,
                                    color: record.done
                                        ? Color(0xFF62E6A2)
                                        : Colors.redAccent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    record.done ? 'Selesai' : 'Belum',
                                    style: TextStyle(
                                      color: record.done
                                          ? Color(0xFF62E6A2)
                                          : Colors.redAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statPill(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF1B232A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Color(0xFF62E6A2)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF9AA5AE), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

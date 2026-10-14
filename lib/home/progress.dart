import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout_session.dart';
import '../providers/progress_history_provider.dart';
import '../providers/workout_provider.dart';
import 'workout_history_view.dart';

const Color _bg = Color(0xFF0B0F12);
const Color _card = Color(0xFF151B20);
const Color _green = Color(0xFF62E6A2);
const Color _muted = Color(0xFF9AA5AE);

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String? _selectedExercise;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<ProgressHistoryProvider>();
    final workout = context.watch<WorkoutProvider>();

    final records = history.personalRecords;
    final names = history.exerciseNames;

    final selected =
        names.contains(_selectedExercise)
            ? _selectedExercise!
            : (names.isNotEmpty ? names.first : null);

    final loadRecords =
        selected == null
            ? <WorkoutExerciseRecord>[]
            : history.loadProgress(selected);

    final week = history.weeklySessions;
    final weekTotal = week.fold<int>(0, (sum, value) => sum + value);

    final latest = history.sessions;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pantau perkembangan latihanmu',
              style: TextStyle(color: _muted),
            ),
            const SizedBox(height: 22),

            // RINGKASAN RIWAYAT
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Total Sesi',
                    '${history.sessions.length}',
                    Icons.calendar_month_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    'PR Tercatat',
                    '${records.length}',
                    Icons.emoji_events_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // SIMPAN SNAPSHOT LATIHAN
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFF183D2D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _green.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simpan latihan hari ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Split saat ini: ${workout.selectedSplit}. '
                    'Latihan yang sudah ditandai selesai akan ikut tercatat.',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: _bg,
                      ),
                      onPressed: () async {
                        if (workout.exercises.isEmpty) return;

                        await context
                            .read<ProgressHistoryProvider>()
                            .recordWorkout(workout);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sesi latihan berhasil disimpan.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Simpan Sesi'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // GRAFIK MINGGUAN
            _sectionTitle('Grafik Mingguan'),
            const SizedBox(height: 6),
            const Text(
              'Jumlah sesi latihan setiap hari minggu ini',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _panel(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      const labels = [
                        'Sen',
                        'Sel',
                        'Rab',
                        'Kam',
                        'Jum',
                        'Sab',
                        'Min',
                      ];

                      final maxValue = week.fold<int>(
                        1,
                        (a, b) => a > b ? a : b,
                      );
                      final value = week[index];

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$value',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 100 * value / maxValue + 4,
                                decoration: BoxDecoration(
                                  color: _green.withValues(
                                    alpha: value == 0 ? 0.15 : 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                labels[index],
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$weekTotal sesi minggu ini',
                      style: const TextStyle(
                        color: _green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // GRAFIK BEBAN
            _sectionTitle('Grafik Perkembangan Beban'),
            const SizedBox(height: 12),
            if (names.isEmpty)
              _panel(
                child: const Text(
                  'Simpan sesi latihan terlebih dahulu untuk melihat grafik beban.',
                  style: TextStyle(color: _muted),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected,
                    isExpanded: true,
                    dropdownColor: _card,
                    style: const TextStyle(color: Colors.white),
                    items:
                        names.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedExercise = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _panel(
                child:
                    loadRecords.isEmpty
                        ? const Text(
                          'Belum ada data beban untuk latihan ini.',
                          style: TextStyle(color: _muted),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Beban terakhir: ${_formatWeight(loadRecords.last.weight)} kg',
                              style: const TextStyle(
                                color: _green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: CustomPaint(
                                painter: _LoadChartPainter(
                                  values:
                                      loadRecords.map((e) => e.weight).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Urutan data dari sesi lama ke sesi terbaru.',
                              style: TextStyle(color: _muted, fontSize: 11),
                            ),
                          ],
                        ),
              ),
            ],
            const SizedBox(height: 26),

            // PERSONAL RECORDS
            _sectionTitle('Personal Records (PR)'),
            const SizedBox(height: 12),
            if (records.isEmpty)
              _panel(
                child: const Text(
                  'Belum ada PR. Simpan sesi dengan latihan yang sudah selesai.',
                  style: TextStyle(color: _muted),
                ),
              )
            else
              ..._sortedRecords(records).map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: _green, size: 27),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${_formatWeight(entry.value)} kg',
                        style: const TextStyle(
                          color: _green,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 26),

            // RIWAYAT
            const WorkoutHistoryView(),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, double>> _sortedRecords(Map<String, double> records) {
    final entries =
        records.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _green),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: _muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatWeight(double weight) =>
      weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1);

  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}

class _LoadChartPainter extends CustomPainter {
  final List<double> values;

  _LoadChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const left = 8.0;
    const right = 8.0;
    const top = 16.0;
    const bottom = 16.0;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    final gridPaint =
        Paint()
          ..color = Colors.white12
          ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x =
          values.length == 1
              ? size.width / 2
              : left + chartWidth * i / (values.length - 1);

      final normalized = range == 0 ? 0.5 : (values[i] - minValue) / range;
      final y = top + chartHeight * (1 - normalized);

      points.add(Offset(x, y));
    }

    final linePaint =
        Paint()
          ..color = _green
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, linePaint);
    }

    final dotPaint =
        Paint()
          ..color = _green
          ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoadChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

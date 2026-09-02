import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'wellness_reports_page.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late Future<Map<String, dynamic>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = ApiService.getWeeklyMoodSummary();
  }

  Future<void> _refresh() async {
    setState(() => _summaryFuture = ApiService.getWeeklyMoodSummary());
    await _summaryFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text('Your Insights', style: TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Wellness reports',
            icon: const Icon(Icons.summarize_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WellnessReportsPage()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return _MessageState(message: 'Could not load your insights.', actionLabel: 'Try again', onAction: _refresh);

          final data = snapshot.data!;
          final summary = Map<String, dynamic>.from(data['summary'] as Map? ?? {});
          final entries = (data['entries'] as List<dynamic>? ?? const []).map((entry) => Map<String, dynamic>.from(entry as Map)).toList();
          final total = _number(summary['totalCheckIns']).toInt();
          if (total == 0) return _MessageState(message: 'Complete a mood check-in to start seeing your weekly patterns.', actionLabel: 'Refresh', onAction: _refresh);

          final mood = _number(summary['averageMood']);
          final stress = _number(summary['averageStress']);
          final sleep = _number(summary['averageSleep']);
          final energy = _number(summary['averageEnergy']);
          final points = entries.map((entry) => _number(entry['mood'])).toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('THIS WEEK', style: TextStyle(fontSize: 11, letterSpacing: 1.2, color: Color(0xFF56745B), fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('A gentle look at your patterns.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF403E38))),
                const SizedBox(height: 20),
                _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  SizedBox(height: 160, width: double.infinity,child: CustomPaint(painter: MoodChartPainter(points))),
                  const SizedBox(height: 14),
                  Text('${mood.toStringAsFixed(1)} / 5', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF56745B))),
                  const Text('Average mood from your check-ins', style: TextStyle(color: Color(0xFF827C73))),
                ])),
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(child: InsightCard(title: 'Stress', value: '${stress.toStringAsFixed(1)} / 5')),
                  const SizedBox(width: 10),
                  Expanded(child: InsightCard(title: 'Sleep', value: '${sleep.toStringAsFixed(1)} h')),
                ]),
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(child: InsightCard(title: 'Energy', value: '${energy.round()}%')),
                  const SizedBox(width: 10),
                  Expanded(child: InsightCard(title: 'Check-ins', value: '$total')),
                ]),
                const SizedBox(height: 22),
                _card(color: const Color(0xFFE7E0EF), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('WEEKLY REFLECTION', style: TextStyle(fontSize: 11, letterSpacing: 1, color: Color(0xFF685D79), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(_reflection(mood, stress, sleep), style: const TextStyle(fontSize: 16, height: 1.4)),
                ])),
                const SizedBox(height: 15),
                _card(color: const Color(0xFFF6EDCC), child: const Text('These patterns are based on your self-reported check-ins and are not a medical diagnosis.', style: TextStyle(color: Color(0xFF827C73), height: 1.4))),
              ],
            ),
          );
        },
      ),
    );
  }

  String _reflection(double mood, double stress, double sleep) {
    if (stress >= 4) return 'Your average stress was high this week. Consider making space for a small calming activity or a supportive conversation.';
    if (sleep < 6) return 'You reported less sleep on average this week. Gentle rest routines may help you feel more supported.';
    if (mood <= 2) return 'Your check-ins suggest a more positive week overall. Notice the routines or moments that helped.';
    if (mood >= 4) return 'Your check-ins suggest some difficult feelings this week. Be kind to yourself and consider reaching out for support if needed.';
    return 'Your check-ins show a mixed or steady week. Keeping a regular check-in habit can help you notice what supports you.';
  }

  Widget _card({required Widget child, Color color = Colors.white}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE9E3D9))),
    child: child,
  );
}

double _number(dynamic value) => value is num ? value.toDouble() : 0;

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.actionLabel, required this.onAction});
  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF827C73), height: 1.4)),
      const SizedBox(height: 12),
      FilledButton(onPressed: onAction, child: Text(actionLabel)),
    ]),
  ));
}

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9E3D9))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF827C73))),
      const SizedBox(height: 7),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF56745B))),
    ]),
  );
}

class MoodChartPainter extends CustomPainter {
  MoodChartPainter(this.points);
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()..color = const Color(0xFF56745B)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1 ? size.width / 2 : index * size.width / (points.length - 1);
      final y = (((points[index].clamp(1, 5) - 1) / 4) * (size.height - 16) + 8).toDouble();
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MoodChartPainter oldDelegate) => oldDelegate.points != points;
}

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'assessment_page.dart';

class AssessmentListPage extends StatefulWidget {
  const AssessmentListPage({super.key});

  @override
  State<AssessmentListPage> createState() => _AssessmentListPageState();
}

class _AssessmentListPageState extends State<AssessmentListPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiService.getAssessmentHistory();
  }

  Future<void> _openAssessment(String type, String title) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AssessmentPage(type: type, title: title)));
    if (mounted) setState(() => _historyFuture = ApiService.getAssessmentHistory());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFAF8F3),
    appBar: AppBar(backgroundColor: const Color(0xFFFAF8F3), elevation: 0, title: const Text('Assessments', style: TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.bold))),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Understand your wellbeing', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF403E38))),
      const SizedBox(height: 8),
      const Text('These evidence-based screening questionnaires support self-awareness. They do not provide a diagnosis.', style: TextStyle(color: Color(0xFF827C73), fontSize: 15, height: 1.4)),
      const SizedBox(height: 22),
      _AssessmentCard(title: 'PHQ-9', description: 'A 9-question check-in about low mood and wellbeing over the last two weeks.', color: const Color(0xFFDDEBD9), onPressed: () => _openAssessment('phq9', 'PHQ-9')),
      const SizedBox(height: 14),
      _AssessmentCard(title: 'GAD-7', description: 'A 7-question check-in about anxiety and worry over the last two weeks.', color: const Color(0xFFE7E0EF), onPressed: () => _openAssessment('gad7', 'GAD-7')),
      const SizedBox(height: 28),
      const Text('Previous Results', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      FutureBuilder<List<Map<String, dynamic>>>(future: _historyFuture, builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator()));
        if (snapshot.hasError) return TextButton(onPressed: () => setState(() => _historyFuture = ApiService.getAssessmentHistory()), child: const Text('Could not load history. Try again.'));
        final history = snapshot.data!;
        if (history.isEmpty) return const Text('No completed assessments yet.', style: TextStyle(color: Color(0xFF827C73)));
        return Column(children: history.take(5).map(_historyCard).toList());
      }),
    ]),
  );

  Widget _historyCard(Map<String, dynamic> item) {
    final result = Map<String, dynamic>.from(item['result'] as Map? ?? {});
    final date = DateTime.tryParse(item['date'] as String? ?? '');
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE9E3D9))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${(item['type'] as String? ?? '').toUpperCase()} — ${_readable(result['level'])}', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Text('Score: ${item['score'] ?? '-'}${date == null ? '' : ' · ${date.day}/${date.month}/${date.year}'}', style: const TextStyle(color: Color(0xFF827C73))),
    ]));
  }

  String _readable(dynamic value) => (value as String? ?? 'not available').replaceAll('_', ' ');
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.title, required this.description, required this.color, required this.onPressed});
  final String title;
  final String description;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)), child: Row(children: [
    const Icon(Icons.assignment_outlined, size: 30, color: Color(0xFF56745B)), const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF827C73), height: 1.3)), const SizedBox(height: 8), const Text('About 2 minutes', style: TextStyle(fontSize: 11, color: Color(0xFF827C73)))])),
    const SizedBox(width: 8), ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF56745B), foregroundColor: Colors.white), child: const Text('Start')),
  ]));
}

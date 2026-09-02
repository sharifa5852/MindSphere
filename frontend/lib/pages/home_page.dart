import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/quick_action.dart';
import '../widgets/soft_card.dart';
import '../widgets/stat_card.dart';
import 'ai_companion_page.dart';
import 'assessment_list_page.dart';
import 'insights_page.dart';
import 'journal_page.dart';
import 'mood_checkin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final name = FirebaseAuth.instance.currentUser?.displayName?.trim();
    final greetingName = name == null || name.isEmpty ? 'there' : name;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            final summary = snapshot.hasData
                ? Map<String, dynamic>.from(snapshot.data!['summary'] as Map? ?? {})
                : <String, dynamic>{};
            final total = _number(summary['totalCheckIns']).toInt();
            final mood = _number(summary['averageMood']);
            final stress = _number(summary['averageStress']);
            final sleep = _number(summary['averageSleep']);
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Text(_todayLabel(), style: const TextStyle(fontSize: 11, letterSpacing: 1.2, color: Color(0xFF56745B), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Good ${_timeGreeting()},\n$greetingName', style: const TextStyle(fontSize: 29, height: 1.15, fontWeight: FontWeight.bold, color: Color(0xFF403E38))),
                  const SizedBox(height: 20),
                  if (snapshot.connectionState != ConnectionState.done)
                    const SoftCard(backgroundColor: Color(0xFFDDEBD9), child: Center(child: CircularProgressIndicator()))
                  else if (snapshot.hasError)
                    SoftCard(backgroundColor: const Color(0xFFF6EDCC), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Your weekly data is unavailable right now.', style: TextStyle(color: Color(0xFF827C73))),
                      TextButton(onPressed: _refresh, child: const Text('Try again')),
                    ]))
                  else
                    _moodSummaryCard(total, mood),
                  const SizedBox(height: 16),
                  SoftCard(backgroundColor: const Color(0xFFE7E0EF), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("TODAY'S INSIGHT", style: TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold, color: Color(0xFF685D79))),
                    const SizedBox(height: 7),
                    Text(_homeInsight(total, mood, stress, sleep), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  ])),
                  const SizedBox(height: 22),
                  const Text('Quick check-in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF403E38))),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2, childAspectRatio: 1.45, mainAxisSpacing: 12, crossAxisSpacing: 12, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _action('Mood', const MoodCheckInPage()),
                      _action('Insights', const InsightsPage()),
                      _action('Journal', const JournalPage()),
                      _action('Talk to AI', const AiCompanionPage()),
                      _action('Assessment', const AssessmentListPage()),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text('Your week', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF403E38))),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: StatCard(label: 'Mood', value: total == 0 ? '-' : '${mood.toStringAsFixed(1)}/5')),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(label: 'Stress', value: total == 0 ? '-' : '${stress.toStringAsFixed(1)}/5')),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(label: 'Sleep', value: total == 0 ? '-' : '${sleep.toStringAsFixed(1)}h')),
                  ]),
                  const SizedBox(height: 18),
                  const SoftCard(backgroundColor: Color(0xFFF6EDCC), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Small reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Your wellbeing is a process. One small check-in is enough for today.', style: TextStyle(color: Color(0xFF827C73))),
                  ])),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _moodSummaryCard(int total, double mood) => SoftCard(
    backgroundColor: const Color(0xFFDDEBD9),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your week so far', style: TextStyle(color: Color(0xFF827C73))),
        const SizedBox(height: 4),
        Text(total == 0 ? 'No check-ins yet' : '${mood.toStringAsFixed(1)} / 5 average mood', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
      Icon(total == 0 ? Icons.sentiment_neutral : Icons.favorite_outline, size: 38, color: const Color(0xFF56745B)),
    ]),
  );

  QuickAction _action(String label, Widget page) => QuickAction(
    icon: _actionSymbol(label),
    label: label,
    onTap: () async {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      if (mounted) _refresh();
    },
  );

  String _actionSymbol(String label) {
    switch (label) {
      case 'Mood': return String.fromCharCode(0x263A);
      case 'Insights': return String.fromCharCode(0x2261);
      case 'Journal': return String.fromCharCode(0x270E);
      case 'Talk to AI': return String.fromCharCode(0x2726);
      default: return String.fromCharCode(0x2611);
    }
  }

  String _homeInsight(int total, double mood, double stress, double sleep) {
    if (total == 0) return 'Start with a short mood check-in whenever you are ready.';
    if (stress >= 4) return 'Your recent check-ins show high stress. A small pause may help today.';
    if (sleep < 6) return 'Your recent sleep has been shorter. Consider keeping today a little gentler.';
    if (mood <= 2) return 'Your recent check-ins have been more positive. Keep noticing what is helping.';
    return 'You have completed $total check-in${total == 1 ? '' : 's'} this week. Your reflections are building a useful pattern.';
  }

  String _todayLabel() {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final now = DateTime.now();
    return '${names[now.weekday - 1].toUpperCase()}, ${now.day}/${now.month}/${now.year}';
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

double _number(dynamic value) => value is num ? value.toDouble() : 0;

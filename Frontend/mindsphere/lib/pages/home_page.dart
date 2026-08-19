import 'package:flutter/material.dart';
import 'mood_checkin_page.dart';
import 'journal_page.dart';
import 'ai_companion_page.dart';
import 'assessment_list_page.dart';
import '../widgets/soft_card.dart';
import '../widgets/section_title.dart';
import '../widgets/quick_action.dart';
import '../widgets/stat_card.dart';
import '../widgets/tag.dart';
import 'insights_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            // ------------------------------------------------
            // DATE
            // ------------------------------------------------

            const Text(
              'WEDNESDAY, AUGUST 12',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                color: Color(0xFF56745B),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // ------------------------------------------------
            // GREETING
            // ------------------------------------------------

            const Text(
              'Good evening,\nSharifatun 🌿',
              style: TextStyle(
                fontSize: 29,
                height: 1.15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF403E38),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // TODAY'S MOOD
            // ------------------------------------------------

            SoftCard(
              backgroundColor: const Color(0xFFDDEBD9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How are you doing today?',
                        style: TextStyle(
                          color: Color(0xFF827C73),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Feeling okay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '😊',
                    style: TextStyle(
                      fontSize: 42,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ------------------------------------------------
            // TODAY'S INSIGHT
            // ------------------------------------------------

            SoftCard(
              backgroundColor: const Color(0xFFE7E0EF),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "✦ TODAY'S INSIGHT",
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF685D79),
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Your mood has been more positive than last week.',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------
            // QUICK CHECK-IN
            // ------------------------------------------------

            const SectionTitle(
              text: 'Quick check-in',
            ),

            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.45,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                QuickAction(
                  icon: '😊',
                  label: 'Mood',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodCheckInPage(),
                      ),
                    );
                  },
                ),
                QuickAction(
                  icon: '📊',
                  label: 'Insights',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InsightsPage(),
                      ),
                    );
                  },
                ),
                QuickAction(
                  icon: '📔',
                  label: 'Journal',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JournalPage(),
                      ),
                    );
                  },
                ),
                QuickAction(
                  icon: '✦',
                  label: 'Talk to AI',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AiCompanionPage(),
                      ),
                    );
                  },
                ),
                QuickAction(
                  icon: '📝',
                  label: 'Assessment',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssessmentListPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // ------------------------------------------------
            // JOURNAL MOOD LENS
            // ------------------------------------------------

            const SectionTitle(
              text: 'Journal Mood Lens',
            ),

            SoftCard(
              backgroundColor: const Color(0xFFEEF5EB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: Color(0xFFA8C3A0),
                        child: Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF56745B),
                          size: 19,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trained emotion model',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Last journal analysis',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF827C73),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    children: [
                      Tag(
                        text: '😣 Stressed',
                        active: true,
                      ),
                      Tag(
                        text: '😐 Neutral',
                      ),
                      Tag(
                        text: '🌿 Calm',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JournalPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Open reflection →',
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------
            // YOUR WEEK
            // ------------------------------------------------

            const SectionTitle(
              text: 'Your week',
            ),

            Row(
              children: const [
                Expanded(
                  child: StatCard(
                    label: 'Mood',
                    value: '😊 ↑',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Stress',
                    value: '↓ 12%',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Sleep',
                    value: '7h 20m',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ------------------------------------------------
            // REMINDER
            // ------------------------------------------------

            SoftCard(
              backgroundColor: const Color(0xFFF6EDCC),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Small reminder 🌱',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Take a few minutes for yourself today.',
                    style: TextStyle(
                      color: Color(0xFF827C73),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

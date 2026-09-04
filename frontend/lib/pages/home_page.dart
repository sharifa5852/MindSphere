import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'ai_companion_page.dart';
import 'assessment_list_page.dart';
import 'insights_page.dart';
import 'journal_page.dart';
import 'mood_checkin_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _summaryFuture;

  // ============================================================
  // MINDSPHERE COLOR SYSTEM
  // ============================================================

  static const Color primary = Color(0xFFBFE3C0);
  static const Color paleMint = Color(0xFFD9F0DC);
  static const Color freshMint = Color(0xFFC9EACB);
  static const Color calmMint = Color(0xFFB5DFC0);
  static const Color sageMint = Color(0xFFAED8B8);
  static const Color eucalyptus = Color(0xFFA8D5B5);
  static const Color celadon = Color(0xFFB7DCC1);
  static const Color morningMint = Color(0xFFC8E7D0);

  static const Color background = Color(0xFFF3FAF5);
  static const Color darkGreen = Color(0xFF2D6A4F);
  static const Color forestText = Color(0xFF1B4332);
  static const Color ink = Color(0xFF13291D);
  static const Color mutedText = Color(0xFF5B7568);

  @override
  void initState() {
    super.initState();
    _summaryFuture = ApiService.getWeeklyMoodSummary();
  }

  Future<void> _refresh() async {
    setState(() {
      _summaryFuture = ApiService.getWeeklyMoodSummary();
    });

    await _summaryFuture;
  }

  @override
  Widget build(BuildContext context) {
    final name = FirebaseAuth.instance.currentUser?.displayName?.trim();
    final greetingName =
        name == null || name.isEmpty ? 'there' : name.split(' ').first;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            final summary = snapshot.hasData
                ? Map<String, dynamic>.from(
                    snapshot.data!['summary'] as Map? ?? {},
                  )
                : <String, dynamic>{};

            final total = _number(summary['totalCheckIns']).toInt();
            final mood = _number(summary['averageMood']);
            final stress = _number(summary['averageStress']);
            final sleep = _number(summary['averageSleep']);

            return RefreshIndicator(
              color: darkGreen,
              backgroundColor: Colors.white,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                children: [
                  // ======================================================
                  // TOP HEADER
                  // ======================================================
                  _topHeader(greetingName),

                  const SizedBox(height: 18),

                  // ======================================================
                  // WEEKLY MOOD HERO CARD
                  // ======================================================
                  if (snapshot.connectionState != ConnectionState.done)
                    _loadingCard()
                  else if (snapshot.hasError)
                    _errorCard()
                  else
                    _moodSummaryCard(total, mood),

                  const SizedBox(height: 18),

                  // ======================================================
                  // TODAY'S INSIGHT
                  // ======================================================
                  _insightCard(
                    total,
                    mood,
                    stress,
                    sleep,
                  ),

                  const SizedBox(height: 28),

                  // ======================================================
                  // SECTION TITLE
                  // ======================================================
                  _sectionHeader(
                    title: 'Check in with yourself',
                    subtitle: 'A tiny step can change the whole day.',
                  ),

                  const SizedBox(height: 14),

                  // ======================================================
                  // QUICK ACTIONS
                  // ======================================================
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.34,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _actionTile(
                        label: 'Mood',
                        subtitle: 'How are you feeling?',
                        icon: Icons.favorite_rounded,
                        backgroundColor: freshMint,
                        iconBackground: paleMint,
                        iconColor: darkGreen,
                        page: const MoodCheckInPage(),
                      ),
                      _actionTile(
                        label: 'Insights',
                        subtitle: 'See your patterns',
                        icon: Icons.insights_rounded,
                        backgroundColor: paleMint,
                        iconBackground: morningMint,
                        iconColor: darkGreen,
                        page: const InsightsPage(),
                      ),
                      _actionTile(
                        label: 'Journal',
                        subtitle: 'Put it into words',
                        icon: Icons.edit_note_rounded,
                        backgroundColor: celadon,
                        iconBackground: calmMint,
                        iconColor: forestText,
                        page: const JournalPage(),
                      ),
                      _actionTile(
                        label: 'Talk to AI',
                        subtitle: 'A space to talk',
                        icon: Icons.auto_awesome_rounded,
                        backgroundColor: morningMint,
                        iconBackground: freshMint,
                        iconColor: darkGreen,
                        page: const AiCompanionPage(),
                      ),
                      _actionTile(
                        label: 'Assessment',
                        subtitle: 'Know yourself better',
                        icon: Icons.checklist_rounded,
                        backgroundColor: calmMint,
                        iconBackground: paleMint,
                        iconColor: forestText,
                        page: const AssessmentListPage(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ======================================================
                  // YOUR WEEK
                  // ======================================================
                  _sectionHeader(
                    title: 'Your week',
                    subtitle: 'A gentle snapshot of your wellbeing.',
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _statTile(
                          label: 'Mood',
                          value: total == 0
                              ? '--'
                              : '${mood.toStringAsFixed(1)}/5',
                          icon: Icons.sentiment_satisfied_alt_rounded,
                          accent: freshMint,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statTile(
                          label: 'Stress',
                          value: total == 0
                              ? '--'
                              : '${stress.toStringAsFixed(1)}/5',
                          icon: Icons.spa_rounded,
                          accent: paleMint,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statTile(
                          label: 'Sleep',
                          value: total == 0
                              ? '--'
                              : '${sleep.toStringAsFixed(1)}h',
                          icon: Icons.nightlight_round,
                          accent: morningMint,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ======================================================
                  // REMINDER CARD
                  // ======================================================
                  _reminderCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ====================================================================
  // TOP HEADER
  // ====================================================================

  Widget _topHeader(String greetingName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            paleMint,
            primary,
            background,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.58),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _todayLabel(),
                    style: const TextStyle(
                      fontSize: 9.5,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Good ${_timeGreeting()},',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: forestText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  greetingName,
                  style: const TextStyle(
                    fontSize: 32,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Take a little moment for yourself today.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.white.withOpacity(0.7),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(),
                  ),
                );
              },
              child: Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                child: Text(
                  _initials(greetingName),
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // HERO MOOD CARD
  // ====================================================================

  Widget _moodSummaryCard(int total, double mood) {
    final hasData = total > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            paleMint,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.58),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'THIS WEEK',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  hasData ? '${mood.toStringAsFixed(1)} / 5' : 'Start gently',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: forestText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasData ? 'average mood' : 'No check-ins yet',
                  style: const TextStyle(
                    fontSize: 13,
                    color: mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  hasData
                      ? '$total check-in${total == 1 ? '' : 's'} recorded'
                      : 'Your first check-in is waiting.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: forestText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                hasData ? Icons.favorite_rounded : Icons.self_improvement_rounded,
                size: 38,
                color: darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // INSIGHT CARD
  // ====================================================================

  Widget _insightCard(
    int total,
    double mood,
    double stress,
    double sleep,
  ) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: paleMint,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: paleMint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: darkGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S INSIGHT",
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w800,
                    color: mutedText,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _homeInsight(total, mood, stress, sleep),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: forestText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // QUICK ACTION TILE
  // ====================================================================

  Widget _actionTile({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color iconBackground,
    required Color iconColor,
    required Widget page,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashColor: darkGreen.withOpacity(0.08),
        highlightColor: Colors.white.withOpacity(0.16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );

          if (mounted) {
            _refresh();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.42),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 14,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: forestText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // STAT TILE
  // ====================================================================

  Widget _statTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 17,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: forestText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: mutedText,
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // REMINDER
  // ====================================================================

  Widget _reminderCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A small reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your wellbeing is a process. One small check-in is enough for today.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFFD9F0DC),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // SECTION HEADER
  // ====================================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: mutedText,
          ),
        ),
      ],
    );
  }

  // ====================================================================
  // LOADING
  // ====================================================================

  Widget _loadingCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: paleMint,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: darkGreen,
        ),
      ),
    );
  }

  // ====================================================================
  // ERROR
  // ====================================================================

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: calmMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: paleMint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: darkGreen,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'Your weekly data is unavailable right now.',
              style: TextStyle(
                fontSize: 13,
                color: mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _refresh,
            style: TextButton.styleFrom(
              foregroundColor: darkGreen,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // HELPERS
  // ====================================================================

  String _homeInsight(
    int total,
    double mood,
    double stress,
    double sleep,
  ) {
    if (total == 0) {
      return 'Start with a short mood check-in whenever you are ready.';
    }

    if (stress >= 4) {
      return 'Your recent check-ins show high stress. A small pause may help today.';
    }

    if (sleep < 6) {
      return 'Your recent sleep has been shorter. Consider keeping today a little gentler.';
    }

    if (mood <= 2) {
      return 'Your recent check-ins have been more difficult. Be extra gentle with yourself today.';
    }

    return 'You have completed $total check-in${total == 1 ? '' : 's'} this week. Your reflections are building a useful pattern.';
  }

  String _todayLabel() {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final now = DateTime.now();

    return '${names[now.weekday - 1].toUpperCase()} • '
        '${now.day}/${now.month}/${now.year}';
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return 'M';

    final parts = name.trim().split(' ');

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
        '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

double _number(dynamic value) {
  return value is num ? value.toDouble() : 0;
}
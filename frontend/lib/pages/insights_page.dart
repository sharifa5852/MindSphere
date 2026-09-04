
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'wellness_reports_page.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  // ==========================================================
  // MINDSPHERE — SOFT MINT DESIGN SYSTEM
  // ==========================================================

  static const Color primary = Color(0xFFBFE3C0);
  static const Color paleMint = Color(0xFFD9F0DC);
  static const Color freshMint = Color(0xFFC9EACB);
  static const Color calmMint = Color(0xFFB5DFC0);
  static const Color sageMint = Color(0xFFAED8B8);
  static const Color eucalyptus = Color(0xFFA8D5B5);
  static const Color dustyMint = Color(0xFFA5D0B2);
  static const Color celadon = Color(0xFFB7DCC1);
  static const Color morningMint = Color(0xFFC8E7D0);

  static const Color background = Color(0xFFF3FAF5);
  static const Color darkGreen = Color(0xFF2D6A4F);
  static const Color forestText = Color(0xFF1B4332);
  static const Color ink = Color(0xFF13291D);
  static const Color mutedText = Color(0xFF5B7568);

  late Future<Map<String, dynamic>> _summaryFuture;

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
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _loadingState();
            }

            if (snapshot.hasError) {
              return _MessageState(
                icon: Icons.cloud_off_rounded,
                title: 'Your insights are taking a little break',
                message: 'Could not load your weekly insights right now.',
                actionLabel: 'Try again',
                onAction: _refresh,
              );
            }

            final data = snapshot.data!;

            final summary = Map<String, dynamic>.from(
              data['summary'] as Map? ?? {},
            );

            final entries = (data['entries'] as List<dynamic>? ?? const [])
                .map(
                  (entry) => Map<String, dynamic>.from(entry as Map),
                )
                .toList();

            final total =
                _number(summary['totalCheckIns']).toInt();

            if (total == 0) {
              return _MessageState(
                icon: Icons.eco_rounded,
                title: 'Your story starts here',
                message:
                    'Complete a mood check-in to start discovering your weekly patterns.',
                actionLabel: 'Refresh',
                onAction: _refresh,
              );
            }

            final mood = _number(summary['averageMood']);
            final stress = _number(summary['averageStress']);
            final sleep = _number(summary['averageSleep']);
            final energy = _number(summary['averageEnergy']);

            final points = entries
                .map((entry) => _number(entry['mood']))
                .toList();

            return RefreshIndicator(
              color: darkGreen,
              backgroundColor: Colors.white,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _topBar(),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        38,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // HERO
                          // ==================================================

                          _hero(
                            mood: mood,
                            total: total,
                          ),

                          const SizedBox(height: 26),

                          // ==================================================
                          // MOOD TREND
                          // ==================================================

                          _sectionHeader(
                            title: 'Your mood story',
                            subtitle:
                                'A gentle look at how things moved this week.',
                          ),

                          const SizedBox(height: 14),

                          _moodChartCard(
                            points: points,
                            averageMood: mood,
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // METRICS
                          // ==================================================

                          _sectionHeader(
                            title: 'At a glance',
                            subtitle:
                                'The little signals behind your week.',
                          ),

                          const SizedBox(height: 14),

                          _metricsGrid(
                            mood: mood,
                            stress: stress,
                            sleep: sleep,
                            energy: energy,
                            total: total,
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // WEEKLY REFLECTION
                          // ==================================================

                          _reflectionCard(
                            mood: mood,
                            stress: stress,
                            sleep: sleep,
                          ),

                          const SizedBox(height: 16),

                          // ==================================================
                          // WELLNESS REPORT
                          // ==================================================

                          _reportCard(),

                          const SizedBox(height: 16),

                          // ==================================================
                          // DISCLAIMER
                          // ==================================================

                          _disclaimer(),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        4,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: forestText,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),

          const Spacer(),

          Material(
            color: paleMint,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const WellnessReportsPage(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: darkGreen,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _hero({
    required double mood,
    required int total,
  }) {
    final moodLabel = _moodLabel(mood);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            paleMint,
            morningMint,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -28,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.17),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 44,
            bottom: -43,
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              const Text(
                'Your wellbeing,\nseen gently.',
                style: TextStyle(
                  fontSize: 29,
                  height: 1.08,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w800,
                  color: forestText,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    mood.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 39,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                      color: forestText,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(
                      left: 5,
                      bottom: 3,
                    ),
                    child: Text(
                      '/ 5',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: mutedText,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.58),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: darkGreen,
                      size: 27,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              Text(
                '$moodLabel  •  $total check-in${total == 1 ? '' : 's'} this week',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION HEADER
  // ==========================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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

  // ==========================================================
  // MOOD CHART
  // ==========================================================

  Widget _moodChartCard({
    required List<double> points,
    required double averageMood,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        17,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: paleMint,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: paleMint,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: darkGreen,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mood trend',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: forestText,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Based on your check-ins',
                      style: TextStyle(
                        fontSize: 10,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: freshMint,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '${averageMood.toStringAsFixed(1)} avg',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: darkGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 185,
            width: double.infinity,
            child: CustomPaint(
              painter: MoodChartPainter(points),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _chartLabel('Earlier'),
              _chartLabel('Now'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: mutedText,
      ),
    );
  }

  // ==========================================================
  // METRICS GRID
  // ==========================================================

  Widget _metricsGrid({
    required double mood,
    required double stress,
    required double sleep,
    required double energy,
    required int total,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'Mood',
                value: '${mood.toStringAsFixed(1)}/5',
                subtitle: 'average',
                icon: Icons.favorite_rounded,
                color: freshMint,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'Stress',
                value: '${stress.toStringAsFixed(1)}/5',
                subtitle: 'average',
                icon: Icons.spa_rounded,
                color: paleMint,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'Energy',
                value: '${energy.round()}%',
                subtitle: 'average',
                icon: Icons.bolt_rounded,
                color: celadon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'Sleep',
                value: '${sleep.toStringAsFixed(1)}h',
                subtitle: 'average',
                icon: Icons.nightlight_round,
                color: morningMint,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _checkInBanner(total),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 14,
                color: mutedText,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: mutedText,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: forestText,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              color: mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkInBanner(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$total check-in${total == 1 ? '' : 's'} completed',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Every little reflection helps reveal your patterns.',
                  style: TextStyle(
                    fontSize: 10,
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

  // ==========================================================
  // WEEKLY REFLECTION
  // ==========================================================

  Widget _reflectionCard({
    required double mood,
    required double stress,
    required double sleep,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: freshMint,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.045),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.58),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: darkGreen,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY REFLECTION',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Something to notice',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: forestText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Text(
            _reflection(
              mood,
              stress,
              sleep,
            ),
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w600,
              color: forestText,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // REPORT CARD
  // ==========================================================

  Widget _reportCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const WellnessReportsPage(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: paleMint,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: paleMint,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.insert_chart_outlined_rounded,
                  color: darkGreen,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View wellness reports',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: forestText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Explore your longer-term wellbeing patterns.',
                      style: TextStyle(
                        fontSize: 11,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: freshMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: darkGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DISCLAIMER
  // ==========================================================

  Widget _disclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: paleMint,
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: mutedText,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'These patterns are based on your self-reported check-ins and are not a medical diagnosis.',
              style: TextStyle(
                fontSize: 10,
                height: 1.45,
                color: mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  Widget _loadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: paleMint,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: darkGreen,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Looking at your week...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: mutedText,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // REFLECTION LOGIC
  // ==========================================================

  String _reflection(
    double mood,
    double stress,
    double sleep,
  ) {
    if (stress >= 4) {
      return 'Your average stress was high this week. Consider making space for a small calming activity or a supportive conversation.';
    }

    if (sleep < 6) {
      return 'You reported less sleep on average this week. Gentle rest routines may help you feel more supported.';
    }

    if (mood <= 2) {
      return 'Your check-ins suggest a more difficult week emotionally. Be gentle with yourself and notice the moments that felt even slightly lighter.';
    }

    if (mood >= 4) {
      return 'Your check-ins suggest a brighter week overall. Notice the routines, people, and moments that may have helped you feel this way.';
    }

    return 'Your check-ins show a mixed or steady week. Keeping a regular check-in habit can help you notice what supports you.';
  }

  String _moodLabel(double mood) {
    if (mood >= 4.5) return 'Feeling very positive';
    if (mood >= 3.5) return 'Feeling positive';
    if (mood >= 2.5) return 'Feeling steady';
    if (mood >= 1.5) return 'A little low';
    return 'Having a difficult week';
  }
}

// ============================================================
// MESSAGE STATE
// ============================================================

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF2D6A4F);
    const forestText = Color(0xFF1B4332);
    const mutedText = Color(0xFF5B7568);
    const paleMint = Color(0xFFD9F0DC);

    return Container(
      color: const Color(0xFFF3FAF5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: paleMint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: darkGreen,
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: forestText,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: mutedText,
                ),
              ),

              const SizedBox(height: 17),

              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MOOD CHART PAINTER
// ============================================================

class MoodChartPainter extends CustomPainter {
  MoodChartPainter(this.points);

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const darkGreen = Color(0xFF2D6A4F);
    const primary = Color(0xFFBFE3C0);
    const paleMint = Color(0xFFD9F0DC);
    const mutedText = Color(0xFF5B7568);

    final chartHeight = size.height - 18;

    // ----------------------------------------------------------
    // Horizontal guide lines
    // ----------------------------------------------------------

    final guidePaint = Paint()
      ..color = paleMint
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = (chartHeight / 4) * i + 9;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        guidePaint,
      );
    }

    // ----------------------------------------------------------
    // Mood line
    // ----------------------------------------------------------

    final linePaint = Paint()
      ..color = darkGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (var index = 0;
        index < points.length;
        index++) {
      final x = points.length == 1
          ? size.width / 2
          : index * size.width /
              (points.length - 1);

      final normalized =
          ((points[index].clamp(1, 5) - 1) / 4)
              .toDouble();

      final y =
          (1 - normalized) * (chartHeight - 16) + 8;

      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // ----------------------------------------------------------
    // Data points
    // ----------------------------------------------------------

    for (var index = 0;
        index < points.length;
        index++) {
      final x = points.length == 1
          ? size.width / 2
          : index * size.width /
              (points.length - 1);

      final normalized =
          ((points[index].clamp(1, 5) - 1) / 4)
              .toDouble();

      final y =
          (1 - normalized) * (chartHeight - 16) + 8;

      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()..color = Colors.white,
      );

      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = darkGreen,
      );
    }

    // ----------------------------------------------------------
    // Mood scale labels
    // ----------------------------------------------------------

    final textStyle = const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w600,
      color: mutedText,
    );

    final labels = ['5', '4', '3', '2', '1'];

    for (int i = 0; i < labels.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final y =
          (chartHeight / 4) * i + 4;

      painter.paint(
        canvas,
        Offset(
          size.width - painter.width,
          y,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant MoodChartPainter oldDelegate,
  ) {
    return oldDelegate.points != points;
  }
}

// ============================================================
// NUMBER HELPER
// ============================================================

double _number(dynamic value) {
  return value is num ? value.toDouble() : 0;
}

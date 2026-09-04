import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'assessment_page.dart';

class AssessmentListPage extends StatefulWidget {
  const AssessmentListPage({super.key});

  @override
  State<AssessmentListPage> createState() => _AssessmentListPageState();
}

class _AssessmentListPageState extends State<AssessmentListPage> {
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
  static const Color softBorder = Color(0xFFE0EEE3);

  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiService.getAssessmentHistory();
  }

  Future<void> _openAssessment(String type, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentPage(
          type: type,
          title: title,
        ),
      ),
    );

    if (mounted) {
      setState(() => _historyFuture = ApiService.getAssessmentHistory());
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _historyFuture = ApiService.getAssessmentHistory();
    });
    await _historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: RefreshIndicator(
                color: darkGreen,
                backgroundColor: Colors.white,
                onRefresh: _refreshHistory,
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  children: [
                    _heroSection(),
                    const SizedBox(height: 22),
                    _sectionHeader(
                      title: 'Choose your check-in',
                      subtitle: 'A few gentle questions can help you notice patterns.',
                    ),
                    const SizedBox(height: 12),
                    _AssessmentCard(
                      type: 'phq9',
                      title: 'PHQ-9',
                      eyebrow: 'MOOD & WELL-BEING',
                      description:
                          'A gentle check-in about mood, energy, sleep, and everyday wellbeing.',
                      duration: '2–3 min',
                      icon: Icons.favorite_outline_rounded,
                      accent: primary,
                      softAccent: paleMint,
                      onPressed: () => _openAssessment('phq9', 'PHQ-9'),
                    ),
                    const SizedBox(height: 13),
                    _AssessmentCard(
                      type: 'gad7',
                      title: 'GAD-7',
                      eyebrow: 'ANXIETY & STRESS',
                      description:
                          'A quick check-in about worry, tension, restlessness, and anxiety.',
                      duration: '2–3 min',
                      icon: Icons.air_rounded,
                      accent: morningMint,
                      softAccent: freshMint,
                      onPressed: () => _openAssessment('gad7', 'GAD-7'),
                    ),
                    const SizedBox(height: 26),
                    _sectionHeader(
                      title: 'Your recent check-ins',
                      subtitle: 'Look back gently — there is no “good” or “bad” result.',
                    ),
                    const SizedBox(height: 12),
                    _historySection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 16, 4),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: forestText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assessments',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'A quiet check-in with yourself',
                  style: TextStyle(
                    fontSize: 10,
                    color: mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: paleMint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.spa_outlined,
                  size: 14,
                  color: darkGreen,
                ),
                SizedBox(width: 5),
                Text(
                  'Take it easy',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroSection() {
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
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -26,
            child: Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.68),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: darkGreen,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR WELLBEING, ONE MOMENT AT A TIME',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w900,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Understand how you’ve been feeling.',
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                        color: forestText,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'These evidence-based screening check-ins are for self-awareness, not diagnosis.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10.5,
            height: 1.35,
            color: mutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _historySection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: softBorder),
            ),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: darkGreen,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _historyErrorCard();
        }

        final history = snapshot.data ?? [];

        if (history.isEmpty) {
          return _emptyHistoryCard();
        }

        return Column(
          children: history.take(5).map(_historyCard).toList(),
        );
      },
    );
  }

  Widget _historyErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: softBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: paleMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: darkGreen,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'We could not load your history right now.',
              style: TextStyle(
                fontSize: 11,
                color: mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _refreshHistory,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: softBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: paleMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: darkGreen,
              size: 25,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No check-ins yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: forestText,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your completed assessments will appear here when you are ready.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.4,
              color: mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> item) {
    final result = Map<String, dynamic>.from(
      item['result'] as Map? ?? {},
    );

    final date = DateTime.tryParse(
      item['date'] as String? ?? '',
    );

    final type = (item['type'] as String? ?? '').toLowerCase();
    final title = type == 'phq9' ? 'PHQ-9' : 'GAD-7';
    final level = _readable(result['level']);
    final isPhq = type == 'phq9';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: softBorder),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isPhq ? paleMint : freshMint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPhq
                  ? Icons.favorite_outline_rounded
                  : Icons.air_rounded,
              size: 21,
              color: darkGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: forestText,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          level,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: darkGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Score: ${item['score'] ?? '-'}'
                  '${date == null ? '' : '  ·  ${date.day}/${date.month}/${date.year}'}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFA0B9A7),
            size: 20,
          ),
        ],
      ),
    );
  }

  String _readable(dynamic value) {
    return (value as String? ?? 'not available').replaceAll('_', ' ');
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.type,
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.duration,
    required this.icon,
    required this.accent,
    required this.softAccent,
    required this.onPressed,
  });

  final String type;
  final String title;
  final String eyebrow;
  final String description;
  final String duration;
  final IconData icon;
  final Color accent;
  final Color softAccent;
  final VoidCallback onPressed;

  static const Color darkGreen = Color(0xFF2D6A4F);
  static const Color forestText = Color(0xFF1B4332);
  static const Color mutedText = Color(0xFF5B7568);
  static const Color background = Color(0xFFF3FAF5);
  static const Color softBorder = Color(0xFFE0EEE3);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: softBorder),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.055),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: softAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: darkGreen,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        fontSize: 8.5,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: forestText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 1,
            color: const Color(0xFFEEF5EF),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: darkGreen,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'For self-awareness',
                  style: TextStyle(
                    fontSize: 9,
                    color: mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

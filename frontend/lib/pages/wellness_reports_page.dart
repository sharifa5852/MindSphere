
import 'package:flutter/material.dart';

import '../services/api_service.dart';

// ============================================================
// MINDSPHERE — SOFT MINT DESIGN SYSTEM
// ============================================================

const _primary = Color(0xFFBFE3C0);
const _paleMint = Color(0xFFD9F0DC);
const _freshMint = Color(0xFFC9EACB);
const _calmMint = Color(0xFFB5DFC0);
const _sageMint = Color(0xFFAED8B8);
const _eucalyptus = Color(0xFFA8D5B5);
const _dustyMint = Color(0xFFA5D0B2);
const _celadon = Color(0xFFB7DCC1);
const _morningMint = Color(0xFFC8E7D0);

const _background = Color(0xFFF3FAF5);
const _darkGreen = Color(0xFF2D6A4F);
const _forestText = Color(0xFF1B4332);
const _ink = Color(0xFF13291D);
const _mutedText = Color(0xFF5B7568);

class WellnessReportsPage extends StatefulWidget {
  const WellnessReportsPage({super.key});

  @override
  State<WellnessReportsPage> createState() =>
      _WellnessReportsPageState();
}

class _WellnessReportsPageState
    extends State<WellnessReportsPage> {
  bool _monthly = false;

  late Future<Map<String, dynamic>> _reportFuture;

  @override
  void initState() {
    super.initState();

    _reportFuture =
        ApiService.getWellnessReport(
      monthly: _monthly,
    );
  }

  Future<void> _load() async {
    setState(() {
      _reportFuture =
          ApiService.getWellnessReport(
        monthly: _monthly,
      );
    });

    await _reportFuture;
  }

  void _changePeriod(bool monthly) {
    if (_monthly == monthly) return;

    setState(() {
      _monthly = monthly;

      _reportFuture =
          ApiService.getWellnessReport(
        monthly: _monthly,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),

            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _reportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState !=
                      ConnectionState.done) {
                    return const _LoadingReport();
                  }

                  if (snapshot.hasError) {
                    return _ReportMessage(
                      message:
                          ApiService.readableError(
                        snapshot.error!,
                      ),
                      action: _load,
                    );
                  }

                  final report =
                      Map<String, dynamic>.from(
                    snapshot.data?['report']
                            as Map? ??
                        {},
                  );

                  final mood =
                      Map<String, dynamic>.from(
                    report['mood'] as Map? ??
                        {},
                  );

                  final journal =
                      Map<String, dynamic>.from(
                    report['journal'] as Map? ??
                        {},
                  );

                  final assessments =
                      (report['assessments']
                                  as List<dynamic>? ??
                              const [])
                          .map(
                            (item) =>
                                Map<String, dynamic>.from(
                              item as Map,
                            ),
                          )
                          .toList();

                  final totalCheckIns =
                      _num(
                    mood['totalCheckIns'],
                  ).toInt();

                  final totalJournal =
                      _num(
                    journal['totalEntries'],
                  ).toInt();

                  final hasData =
                      totalCheckIns > 0 ||
                          totalJournal > 0 ||
                          assessments.isNotEmpty;

                  return RefreshIndicator(
                    color: _darkGreen,
                    backgroundColor: Colors.white,
                    onRefresh: _load,
                    child: ListView(
                      physics:
                          const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        36,
                      ),
                      children: [
                        _periodSwitcher(),

                        const SizedBox(height: 18),

                        _reportHero(
                          totalCheckIns:
                              totalCheckIns,
                          totalJournal:
                              totalJournal,
                          assessmentCount:
                              assessments.length,
                        ),

                        const SizedBox(height: 24),

                        if (!hasData)
                          const _EmptyReport()
                        else ...[
                          _sectionTitle(
                            eyebrow: 'AT A GLANCE',
                            title:
                                'Your wellness snapshot',
                            subtitle:
                                'A simple look at how you have been feeling.',
                          ),

                          const SizedBox(height: 12),

                          _moodSnapshot(
                            mood: mood,
                            totalCheckIns:
                                totalCheckIns,
                          ),

                          const SizedBox(height: 14),

                          _sleepCard(
                            mood: mood,
                          ),

                          const SizedBox(height: 26),

                          _sectionTitle(
                            eyebrow: 'REFLECTIONS',
                            title:
                                'Your journal rhythm',
                            subtitle:
                                'Notice the emotional pattern in your entries.',
                          ),

                          const SizedBox(height: 12),

                          _journalCard(
                            journal: journal,
                          ),

                          const SizedBox(height: 26),

                          _sectionTitle(
                            eyebrow: 'SELF CHECK',
                            title:
                                'Your assessments',
                            subtitle:
                                'A summary of screenings completed during this period.',
                          ),

                          const SizedBox(height: 12),

                          _assessmentSection(
                            assessments:
                                assessments,
                          ),
                        ],

                        const SizedBox(height: 24),

                        _disclaimerCard(
                          report['disclaimer']
                                  as String? ??
                              'These are wellness trends and screening summaries, not medical diagnoses.',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        20,
        4,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder:
                  const CircleBorder(),
              onTap: () =>
                  Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: _forestText,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Wellness Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _ink,
                letterSpacing: -0.4,
              ),
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: _paleMint,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: 13,
                  color: _darkGreen,
                ),
                SizedBox(width: 5),
                Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERIOD SWITCHER
  // ============================================================

  Widget _periodSwitcher() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: _paleMint,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _periodButton(
              title: 'This week',
              selected: !_monthly,
              onTap: () =>
                  _changePeriod(false),
            ),
          ),
          Expanded(
            child: _periodButton(
              title: 'This month',
              selected: _monthly,
              onTap: () =>
                  _changePeriod(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? _darkGreen
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(13),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected
                  ? Colors.white
                  : _mutedText,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _reportHero({
    required int totalCheckIns,
    required int totalJournal,
    required int assessmentCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primary,
            _paleMint,
          ],
        ),
        borderRadius:
            BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -32,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.17,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 42,
            bottom: -42,
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.12,
                ),
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
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.58),
                      borderRadius:
                          BorderRadius
                              .circular(20),
                    ),
                    child: Text(
                      _monthly
                          ? 'MONTH IN REVIEW'
                          : 'WEEK IN REVIEW',
                      style:
                          const TextStyle(
                        fontSize: 8.5,
                        letterSpacing: 1.25,
                        fontWeight:
                            FontWeight.w800,
                        color: _darkGreen,
                      ),
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    '🌿',
                    style: TextStyle(
                      fontSize: 27,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                _monthly
                    ? 'A little look\nback at your month.'
                    : 'A little look\nback at your week.',
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.05,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.8,
                  color: _forestText,
                ),
              ),

              const SizedBox(height: 9),

              const Text(
                'Your wellness story, gathered from the moments you chose to record.',
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.45,
                  color: _mutedText,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _heroStat(
                      icon:
                          Icons.favorite_outline_rounded,
                      value:
                          '$totalCheckIns',
                      label: 'check-ins',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _heroStat(
                      icon:
                          Icons.menu_book_outlined,
                      value:
                          '$totalJournal',
                      label: 'journal entries',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _heroStat(
                      icon:
                          Icons.fact_check_outlined,
                      value:
                          '$assessmentCount',
                      label: 'assessments',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.58),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 17,
            color: _darkGreen,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _forestText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
            color: _darkGreen,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            height: 1.4,
            color: _mutedText,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOOD SNAPSHOT
  // ============================================================

  Widget _moodSnapshot({
    required Map<String, dynamic> mood,
    required int totalCheckIns,
  }) {
    final averageMood =
        _num(mood['averageMood']);

    final averageStress =
        _num(mood['averageStress']);

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(
                icon:
                    Icons.favorite_outline_rounded,
                background: _freshMint,
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mood & stress',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                        color: _forestText,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Based on your check-ins',
                      style: TextStyle(
                        fontSize: 10,
                        color: _mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _paleMint,
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Text(
                  '$totalCheckIns recorded',
                  style:
                      const TextStyle(
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w800,
                    color: _darkGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _bigMetric(
                  value:
                      _formatNumber(
                    averageMood,
                    suffix: '/5',
                  ),
                  label: 'Average mood',
                  icon:
                      Icons.sentiment_satisfied_alt_outlined,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _bigMetric(
                  value:
                      _formatNumber(
                    averageStress,
                    suffix: '/5',
                  ),
                  label: 'Average stress',
                  icon:
                      Icons.psychology_alt_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _insightStrip(
            icon:
                Icons.auto_awesome_rounded,
            text: _moodInsight(
              averageMood,
              averageStress,
            ),
          ),
        ],
      ),
    );
  }

  String _moodInsight(
    double mood,
    double stress,
  ) {
    if (mood >= 4 && stress <= 2) {
      return 'Your recorded moments show a generally calm and positive period.';
    }

    if (mood <= 2 && stress >= 4) {
      return 'Your recent check-ins show a heavier period. Be gentle with yourself.';
    }

    if (stress >= 4) {
      return 'Stress appears to be one of the stronger themes in your recorded check-ins.';
    }

    if (mood >= 4) {
      return 'Your recorded mood has been leaning positive lately.';
    }

    return 'Your check-ins show a mix of experiences — noticing them is already meaningful.';
  }

  // ============================================================
  // SLEEP
  // ============================================================

  Widget _sleepCard({
    required Map<String, dynamic> mood,
  }) {
    final sleep =
        _num(mood['averageSleep']);

    return _card(
      child: Row(
        children: [
          _iconBox(
            icon:
                Icons.nightlight_round,
            background: _calmMint,
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Average sleep',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                    color: _forestText,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your recorded sleep across this period',
                  style: TextStyle(
                    fontSize: 10,
                    color: _mutedText,
                  ),
                ),
              ],
            ),
          ),

          Text(
            _formatNumber(
              sleep,
              suffix: ' h',
            ),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: _darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // JOURNAL
  // ============================================================

  Widget _journalCard({
    required Map<String, dynamic> journal,
  }) {
    final total =
        _num(
      journal['totalEntries'],
    ).toInt();

    final positive =
        _num(
      journal['positiveEntries'],
    ).toInt();

    final neutral =
        _num(
      journal['neutralEntries'],
    ).toInt();

    final negative =
        _num(
      journal['negativeEntries'],
    ).toInt();

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(
                icon:
                    Icons.menu_book_outlined,
                background: _celadon,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Journal rhythm',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                        color: _forestText,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'The emotional tone of your entries',
                      style: TextStyle(
                        fontSize: 10,
                        color: _mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight:
                      FontWeight.w800,
                  color: _darkGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _journalBar(
            positive: positive,
            neutral: neutral,
            negative: negative,
            total: total,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _journalMood(
                  emoji: '😊',
                  value: positive,
                  label: 'Positive',
                  background:
                      _freshMint,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _journalMood(
                  emoji: '😐',
                  value: neutral,
                  label: 'Neutral',
                  background:
                      _paleMint,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _journalMood(
                  emoji: '🌧️',
                  value: negative,
                  label: 'Negative',
                  background:
                      _morningMint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _journalBar({
    required int positive,
    required int neutral,
    required int negative,
    required int total,
  }) {
    if (total == 0) {
      return Container(
        height: 10,
        decoration: BoxDecoration(
          color: _paleMint,
          borderRadius:
              BorderRadius.circular(20),
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(20),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            if (positive > 0)
              Expanded(
                flex: positive,
                child: Container(
                  color: _darkGreen,
                ),
              ),
            if (neutral > 0)
              Expanded(
                flex: neutral,
                child: Container(
                  color: _calmMint,
                ),
              ),
            if (negative > 0)
              Expanded(
                flex: negative,
                child: Container(
                  color: _sageMint,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _journalMood({
    required String emoji,
    required int value,
    required String label,
    required Color background,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
              color: _forestText,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSESSMENTS
  // ============================================================

  Widget _assessmentSection({
    required List<Map<String, dynamic>>
        assessments,
  }) {
    if (assessments.isEmpty) {
      return _card(
        child: Row(
          children: [
            _iconBox(
              icon:
                  Icons.assignment_outlined,
              background: _paleMint,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No assessments were completed during this period.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: _mutedText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: assessments
          .map(
            (item) =>
                Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child:
                  _assessmentCard(item),
            ),
          )
          .toList(),
    );
  }

  Widget _assessmentCard(
    Map<String, dynamic> item,
  ) {
    final type =
        (item['type'] as String? ??
                'assessment')
            .replaceAll('_', ' ');

    final score =
        item['latestScore'] ?? '-';

    final level =
        (item['latestLevel']
                    as String? ??
                'not available')
            .replaceAll('_', ' ');

    return _card(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _freshMint,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: _darkGreen,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalizeWords(type),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                    color: _forestText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Latest score • $score',
                  style: const TextStyle(
                    fontSize: 10,
                    color: _mutedText,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: _paleMint,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Text(
              _capitalizeWords(level),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight:
                    FontWeight.w800,
                color: _darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeWords(String value) {
    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
                  '${word.substring(1)}',
        )
        .join(' ');
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _disclaimerCard(
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _freshMint,
        borderRadius:
            BorderRadius.circular(21),
        border: Border.all(
          color: _celadon,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.65),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: _darkGreen,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.45,
                color: _mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHARED CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(23),
        border: Border.all(
          color: _paleMint,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkGreen.withOpacity(0.035),
            blurRadius: 17,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // ICON BOX
  // ============================================================

  Widget _iconBox({
    required IconData icon,
    required Color background,
  }) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        size: 20,
        color: _darkGreen,
      ),
    );
  }

  // ============================================================
  // BIG METRIC
  // ============================================================

  Widget _bigMetric({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _background,
        borderRadius:
            BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: _darkGreen,
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight:
                  FontWeight.w800,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INSIGHT STRIP
  // ============================================================

  Widget _insightStrip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _paleMint,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: _darkGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                height: 1.4,
                color: _forestText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NUMBER HELPERS
  // ============================================================

  String _formatNumber(
    double value, {
    required String suffix,
  }) {
    if (value == 0) {
      return '-';
    }

    return '${value.toStringAsFixed(1)}$suffix';
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingReport extends StatelessWidget {
  const _LoadingReport();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: _paleMint,
              borderRadius:
                  BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.insights_rounded,
              size: 30,
              color: _darkGreen,
            ),
          ),

          const SizedBox(height: 16),

          const CircularProgressIndicator(
            color: _darkGreen,
            strokeWidth: 2.5,
          ),

          const SizedBox(height: 14),

          const Text(
            'Preparing your report...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _forestText,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Looking gently at your recorded moments.',
            style: TextStyle(
              fontSize: 10,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY REPORT
// ============================================================

class _EmptyReport extends StatelessWidget {
  const _EmptyReport();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: _paleMint,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _paleMint,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🌱',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Your story is still being written.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _forestText,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'There is no recorded wellbeing data for this period yet. Check in, journal, or complete an assessment to begin building your report.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ReportMessage
    extends StatelessWidget {
  const _ReportMessage({
    required this.message,
    required this.action,
  });

  final String message;
  final Future<void> Function() action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _paleMint,
                borderRadius:
                    BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: _darkGreen,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Couldn’t load your report',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w800,
                color: _forestText,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: _mutedText,
              ),
            ),

            const SizedBox(height: 17),

            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: action,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 17,
                ),
                label: const Text(
                  'Try again',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _darkGreen,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 20,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _num(dynamic value) {
  return value is num
      ? value.toDouble()
      : 0;
}


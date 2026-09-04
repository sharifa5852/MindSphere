import 'package:flutter/material.dart';

class EmotionScore {
  const EmotionScore({
    required this.label,
    required this.score,
  });

  final String label;
  final double score;
}

class MoodCheckInResult {
  const MoodCheckInResult({
    required this.mood,
    required this.stress,
    required this.energy,
    required this.sleep,
    required this.socialConnection,
    required this.note,
    this.emotion,
    this.confidence,
    this.otherEmotions = const [],
    this.insight,
    this.analysisModeUsed,
  });

  final int mood;
  final int stress;
  final int energy;
  final int sleep;
  final int socialConnection;
  final String note;

  final String? emotion;
  final double? confidence;
  final List<EmotionScore> otherEmotions;
  final String? insight;
  final String? analysisModeUsed;
}

String _emojiForEmotion(String? emotion) {
  final value = (emotion ?? '').toLowerCase();

  if (value.contains('calm') ||
      value.contains('content') ||
      value.contains('relax')) {
    return '😌';
  }

  if (value.contains('happy') ||
      value.contains('joy') ||
      value.contains('positive') ||
      value.contains('amus')) {
    return '😊';
  }

  if (value.contains('sad') ||
      value.contains('down') ||
      value.contains('griev')) {
    return '😔';
  }

  if (value.contains('anx') ||
      value.contains('nerv') ||
      value.contains('worry')) {
    return '😣';
  }

  if (value.contains('fear') ||
      value.contains('afraid')) {
    return '😨';
  }

  if (value.contains('anger') ||
      value.contains('frustrat') ||
      value.contains('irritat') ||
      value.contains('annoy')) {
    return '😠';
  }

  if (value.contains('tired') ||
      value.contains('overwhelm') ||
      value.contains('exhaust')) {
    return '😞';
  }

  if (value.contains('neutral')) {
    return '😐';
  }

  if (value.contains('surpris') ||
      value.contains('curio')) {
    return '😲';
  }

  return '🌿';
}

String _modeLabel(String? mode) {
  switch (mode) {
    case 'trained_model':
      return 'Trained Model + Gemini';

    case 'gemini':
      return 'Gemini AI';

    case 'fallback':
      return 'General reflection';

    default:
      return '';
  }
}

class MoodResultPage extends StatelessWidget {
  const MoodResultPage({
    super.key,
    required this.result,
  });

  final MoodCheckInResult result;

  // ============================================================
  // MINDSPHERE — SOFT MINT DESIGN SYSTEM
  // ============================================================

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

  // ============================================================
  // MOOD
  // ============================================================

  String get _moodLabel {
    switch (result.mood) {
      case 1:
        return 'Very positive';

      case 2:
        return 'Positive';

      case 3:
        return 'Neutral';

      case 4:
        return 'Negative';

      case 5:
        return 'Very negative';

      default:
        return 'Unspecified';
    }
  }

  String get _moodEmojiText {
    switch (result.mood) {
      case 1:
        return '😊';

      case 2:
        return '🙂';

      case 3:
        return '😐';

      case 4:
        return '😔';

      case 5:
        return '😣';

      default:
        return '🌿';
    }
  }

  String get _stressLabel {
    const labels = [
      'Low',
      'Low',
      'Moderate',
      'High',
      'Very high',
    ];

    return labels[
      result.stress.clamp(1, 5).toInt() - 1
    ];
  }

  String get _socialLabel {
    const labels = [
      'Connected',
      'Normally connected',
      'A little withdrawn',
      'Very withdrawn',
    ];

    return labels[
      result.socialConnection.clamp(1, 4).toInt() - 1
    ];
  }

  String get _reflection {
    final parts = <String>[];

    if (result.mood >= 4) {
      parts.add(
        'Today sounds like it may be feeling difficult.',
      );
    } else if (result.mood <= 2) {
      parts.add(
        'You reported a positive mood today.',
      );
    } else {
      parts.add(
        'You reported a more neutral mood today.',
      );
    }

    if (result.stress >= 4) {
      parts.add(
        'Your stress level was high, so a small pause or calming activity may help.',
      );
    } else if (result.energy <= 30) {
      parts.add(
        'Your energy was low; if you can, give yourself permission to rest and keep things gentle.',
      );
    } else if (result.sleep < 6) {
      parts.add(
        'You reported less than six hours of sleep, so extra care and rest may be useful.',
      );
    } else if (result.socialConnection >= 3) {
      parts.add(
        'You also felt somewhat withdrawn. Reaching out to someone you trust may help if that feels right.',
      );
    } else {
      parts.add(
        'Keep noticing what supports your wellbeing as your day continues.',
      );
    }

    return parts.join(' ');
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final hasEmotionAnalysis =
        result.emotion != null &&
        result.emotion!.trim().isNotEmpty;

    final confidence =
        (result.confidence ?? 0).clamp(0, 1).toDouble();

    final confidencePercent =
        (confidence * 100).round();

    final modeLabel =
        _modeLabel(result.analysisModeUsed);

    final reflection =
        hasEmotionAnalysis &&
                result.insight != null &&
                result.insight!.trim().isNotEmpty
            ? result.insight!
            : _reflection;

    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            // ==================================================
            // TOP BAR
            // ==================================================

            SliverToBoxAdapter(
              child: _topBar(context),
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                34,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // ------------------------------------------
                    // HERO
                    // ------------------------------------------

                    _heroCard(),

                    const SizedBox(height: 24),

                    // ------------------------------------------
                    // EMOTION
                    // ------------------------------------------

                    if (hasEmotionAnalysis) ...[
                      _emotionCard(
                        confidence: confidence,
                        confidencePercent:
                            confidencePercent,
                        modeLabel: modeLabel,
                      ),

                      const SizedBox(height: 20),

                      if (result.otherEmotions.isNotEmpty)
                        _otherEmotionsCard(),

                      if (result.otherEmotions.isNotEmpty)
                        const SizedBox(height: 20),
                    ],

                    // ------------------------------------------
                    // REFLECTION
                    // ------------------------------------------

                    _reflectionCard(reflection),

                    const SizedBox(height: 24),

                    // ------------------------------------------
                    // CHECK-IN DETAILS
                    // ------------------------------------------

                    _sectionHeading(
                      eyebrow: 'TODAY AT A GLANCE',
                      title: 'Your check-in',
                      subtitle:
                          'A little snapshot of how you’re doing.',
                    ),

                    const SizedBox(height: 14),

                    _metricsGrid(),

                    // ------------------------------------------
                    // NOTE
                    // ------------------------------------------

                    if (result.note.trim().isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _noteCard(),
                    ],

                    const SizedBox(height: 22),

                    // ------------------------------------------
                    // DISCLAIMER
                    // ------------------------------------------

                    _disclaimerCard(),

                    const SizedBox(height: 24),

                    // ------------------------------------------
                    // DONE BUTTON
                    // ------------------------------------------

                    _doneButton(context),
                  ],
                ),
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

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        20,
        8,
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

          const Expanded(
            child: Text(
              'Your reflection',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: ink,
                letterSpacing: -0.3,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
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
                  Icons.check_rounded,
                  size: 13,
                  color: darkGreen,
                ),
                SizedBox(width: 4),
                Text(
                  'Complete',
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

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        22,
        22,
        23,
      ),
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
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -48,
            right: -38,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -50,
            right: 42,
            child: Container(
              width: 90,
              height: 90,
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
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.58),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 12,
                      color: darkGreen,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'CHECK-IN COMPLETE',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Emoji
              Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _moodEmojiText,
                    style: const TextStyle(
                      fontSize: 48,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 17),

              const Center(
                child: Text(
                  'Today, you’re feeling',
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Center(
                child: Text(
                  _moodLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: forestText,
                    letterSpacing: -0.7,
                  ),
                ),
              ),

              const SizedBox(height: 13),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.42),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Be gentle with yourself today 🌿',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: darkGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMOTION CARD
  // ============================================================

  Widget _emotionCard({
    required double confidence,
    required int confidencePercent,
    required String modeLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: paleMint,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.045),
            blurRadius: 20,
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
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: paleMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
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
                      'EMOTION INSIGHT',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'What your words may be expressing',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: forestText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main emotion
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Row(
              children: [
                Text(
                  _emojiForEmotion(result.emotion),
                  style: const TextStyle(
                    fontSize: 33,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    result.emotion!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: forestText,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: freshMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$confidencePercent%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Confidence
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Model confidence',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: mutedText,
                ),
              ),
              Text(
                confidencePercent >= 70
                    ? 'High confidence'
                    : confidencePercent >= 40
                        ? 'Moderate confidence'
                        : 'Low confidence',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: darkGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 9,
              backgroundColor: paleMint,
              color: darkGreen,
            ),
          ),

          if (modeLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  size: 12,
                  color: mutedText,
                ),
                const SizedBox(width: 5),
                Text(
                  modeLabel,
                  style: const TextStyle(
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                    color: mutedText,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // OTHER EMOTIONS
  // ============================================================

  Widget _otherEmotionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: paleMint,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'OTHER EMOTIONS',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'A little more beneath the surface',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: forestText,
            ),
          ),

          const SizedBox(height: 17),

          for (
            var i = 0;
            i < result.otherEmotions.length;
            i++
          ) ...[
            _emotionRow(result.otherEmotions[i]),

            if (i < result.otherEmotions.length - 1)
              const SizedBox(height: 15),
          ],
        ],
      ),
    );
  }

  Widget _emotionRow(EmotionScore emotionScore) {
    final percent =
        (emotionScore.score.clamp(0, 1) * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _emojiForEmotion(emotionScore.label),
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                emotionScore.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: forestText,
                ),
              ),
            ),

            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: darkGreen,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: emotionScore.score
                .clamp(0, 1)
                .toDouble(),
            minHeight: 6,
            color: sageMint,
            backgroundColor: paleMint,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REFLECTION
  // ============================================================

  Widget _reflectionCard(String reflection) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            freshMint,
            paleMint,
          ],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.055),
            blurRadius: 18,
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
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.58),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: darkGreen,
                ),
              ),

              const SizedBox(width: 11),

              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'A GENTLE REFLECTION',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Something to notice',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: forestText,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 17),

          Text(
            reflection,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: forestText,
            ),
          ),

          const SizedBox(height: 17),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.favorite_outline_rounded,
                  size: 14,
                  color: mutedText,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Take what feels useful and leave the rest.',
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.35,
                      color: mutedText,
                    ),
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
  // SECTION HEADING
  // ============================================================

  Widget _sectionHeading({
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
            letterSpacing: 1.3,
            fontWeight: FontWeight.w800,
            color: darkGreen,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            height: 1.4,
            color: mutedText,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // METRICS GRID
  // ============================================================

  Widget _metricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _metricCard(
          icon: Icons.bolt_rounded,
          label: 'Energy',
          value: '${result.energy}%',
        ),

        _metricCard(
          icon: Icons.bedtime_rounded,
          label: 'Sleep',
          value: '${result.sleep} hrs',
        ),

        _metricCard(
          icon: Icons.psychology_rounded,
          label: 'Stress',
          value: _stressLabel,
        ),

        _metricCard(
          icon: Icons.people_alt_rounded,
          label: 'Connection',
          value: _socialLabel,
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: paleMint,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: paleMint,
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: darkGreen,
                ),
              ),

              Icon(
                Icons.more_horiz_rounded,
                size: 16,
                color: mutedText.withOpacity(0.45),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: forestText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTE CARD
  // ============================================================

  Widget _noteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: paleMint,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: paleMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 19,
                  color: darkGreen,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'What you shared',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: forestText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              result.note.trim(),
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _disclaimerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(17),
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
            size: 16,
            color: mutedText,
          ),

          SizedBox(width: 9),

          Expanded(
            child: Text(
              'This reflection is based on what you shared today. '
              'It supports self-awareness and is not a medical diagnosis.',
              style: TextStyle(
                fontSize: 9,
                height: 1.45,
                color: mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DONE BUTTON
  // ============================================================

  Widget _doneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 57,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              'Done',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}
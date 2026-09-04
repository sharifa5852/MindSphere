import 'package:flutter/material.dart';

import 'mood_result_page.dart';
import '../services/api_service.dart';

class MoodCheckInPage extends StatefulWidget {
  const MoodCheckInPage({super.key});

  @override
  State<MoodCheckInPage> createState() => _MoodCheckInPageState();
}

class _MoodCheckInPageState extends State<MoodCheckInPage> {
  // ==========================================================
  // DESIGN TOKENS — MINDSPHERE SOFT MINT
  // ==========================================================

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

  int selectedMood = -1;
  int selectedSocial = -1;
  bool _isSaving = false;

  double intensity = 50;
  double energy = 50;
  double sleep = 7;

  String analysisMode = 'gemini';

  final TextEditingController reflectionController =
      TextEditingController();

  final List<String> moods = [
    'Very positive',
    'Positive',
    'Neutral',
    'Negative',
    'Very negative',
  ];

  final List<String> moodEmojis = [
    '😊',
    '🙂',
    '😐',
    '😔',
    '😣',
  ];

  final List<String> socialOptions = [
    'Connected',
    'Normal',
    'A little withdrawn',
    'Very withdrawn',
  ];

  final List<String> socialEmojis = [
    '🤝',
    '🙂',
    '🌿',
    '🫧',
  ];

  @override
  void dispose() {
    reflectionController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SAVE + ANALYZE
  // ==========================================================

  Future<void> analyzeMood() async {
    if (selectedMood == -1 || selectedSocial == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please select your mood and social connection.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final moodValue = selectedMood + 1;
    final stressValue =
        ((intensity / 25).round() + 1).clamp(1, 5).toInt();
    final energyValue = energy.round();
    final sleepValue = sleep.round();
    final socialValue = selectedSocial + 1;
    final noteValue = reflectionController.text;

    try {
      final saved = await ApiService.createMoodEntry(
        mood: moodValue,
        stress: stressValue,
        energy: energyValue,
        sleep: sleepValue,
        socialConnection: socialValue,
        note: noteValue,
      );

      final savedEntry = Map<String, dynamic>.from(
        saved['moodEntry'] as Map? ?? {},
      );

      final entryId = savedEntry['_id'] as String?;

      String? emotion;
      double? confidence;
      List<EmotionScore> otherEmotions = const [];
      String? insight;
      String? modeUsed;

      if (entryId != null) {
        try {
          final analysisResponse =
              await ApiService.analyzeMoodEntry(
            entryId,
            mode: analysisMode,
          );

          final analysis = Map<String, dynamic>.from(
            analysisResponse['analysis'] as Map? ?? {},
          );

          emotion = analysis['emotion'] as String?;
          confidence =
              (analysis['confidence'] as num?)?.toDouble();

          insight = analysis['insight'] as String?;
          modeUsed = analysisResponse['mode'] as String?;

          final otherList =
              analysis['otherEmotions'] as List<dynamic>? ??
                  const [];

          otherEmotions = otherList
              .map(
                (item) => Map<String, dynamic>.from(
                  item as Map,
                ),
              )
              .map(
                (item) => EmotionScore(
                  label: item['label'] as String? ?? '',
                  score:
                      (item['score'] as num?)?.toDouble() ?? 0,
                ),
              )
              .toList();
        } catch (_) {
          // Check-in is already safely saved.
        }
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoodResultPage(
            result: MoodCheckInResult(
              mood: moodValue,
              stress: stressValue,
              energy: energyValue,
              sleep: sleepValue,
              socialConnection: socialValue,
              note: noteValue,
              emotion: emotion,
              confidence: confidence,
              otherEmotions: otherEmotions,
              insight: insight,
              analysisModeUsed: modeUsed,
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiService.readableError(error),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ==========================================================
  // PAGE
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
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
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====================================================
                    // HERO
                    // ====================================================

                    _hero(),

                    const SizedBox(height: 28),

                    // ====================================================
                    // 01 — MOOD
                    // ====================================================

                    _sectionTitle(
                      number: '01',
                      title: 'How are you feeling?',
                      subtitle:
                          'Pick the one that feels closest right now.',
                    ),

                    const SizedBox(height: 14),

                    _moodSelector(),

                    const SizedBox(height: 30),

                    // ====================================================
                    // 02 — BODY + MIND
                    // ====================================================

                    _sectionTitle(
                      number: '02',
                      title: 'Check in with yourself',
                      subtitle:
                          'There are no right or wrong answers.',
                    ),

                    const SizedBox(height: 14),

                    _sliderCard(
                      icon: Icons.psychology_alt_rounded,
                      title: 'Stress',
                      description:
                          'How heavy does everything feel today?',
                      valueText: '${intensity.round()}%',
                      value: intensity,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      leftText: 'Calm',
                      rightText: 'High',
                      onChanged: (value) {
                        setState(() => intensity = value);
                      },
                    ),

                    const SizedBox(height: 12),

                    _sliderCard(
                      icon: Icons.bolt_rounded,
                      title: 'Energy',
                      description:
                          'How much energy do you have right now?',
                      valueText: '${energy.round()}%',
                      value: energy,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      leftText: 'Low',
                      rightText: 'Full',
                      onChanged: (value) {
                        setState(() => energy = value);
                      },
                    ),

                    const SizedBox(height: 12),

                    _sliderCard(
                      icon: Icons.nightlight_round,
                      title: 'Sleep',
                      description:
                          'How much sleep did you get last night?',
                      valueText: '${sleep.round()} hours',
                      value: sleep,
                      min: 0,
                      max: 12,
                      divisions: 12,
                      leftText: '0 hours',
                      rightText: '12 hours',
                      onChanged: (value) {
                        setState(() => sleep = value);
                      },
                    ),

                    const SizedBox(height: 30),

                    // ====================================================
                    // 03 — SOCIAL
                    // ====================================================

                    _sectionTitle(
                      number: '03',
                      title: 'How connected do you feel?',
                      subtitle:
                          'Think about the people around you today.',
                    ),

                    const SizedBox(height: 14),

                    _socialSelector(),

                    const SizedBox(height: 30),

                    // ====================================================
                    // 04 — REFLECTION
                    // ====================================================

                    _sectionTitle(
                      number: '04',
                      title: 'Put it into words',
                      subtitle:
                          'Optional. Sometimes writing helps.',
                    ),

                    const SizedBox(height: 14),

                    _reflectionField(),

                    const SizedBox(height: 30),

                    // ====================================================
                    // 05 — ANALYSIS
                    // ====================================================

                    _sectionTitle(
                      number: '05',
                      title: 'Choose your analysis',
                      subtitle:
                          'How would you like MindSphere to understand your check-in?',
                    ),

                    const SizedBox(height: 14),

                    _analysisSelector(),

                    const SizedBox(height: 28),

                    // ====================================================
                    // CTA
                    // ====================================================

                    _saveButton(),

                    const SizedBox(height: 12),

                    const Text(
                      'Your answers help create a more personal emotional reflection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        20,
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
                  color: forestText,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Mood check-in',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const Spacer(),
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
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: darkGreen,
                ),
                SizedBox(width: 5),
                Text(
                  'Private',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _hero() {
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
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -16,
            child: Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'A MOMENT FOR YOU',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w800,
                    color: darkGreen,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'How are you,\nreally?',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.08,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w800,
                  color: forestText,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Take a breath. There is no perfect answer here — just an honest one.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
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
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: darkGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // MOOD SELECTOR
  // ==========================================================

  Widget _moodSelector() {
    return Column(
      children: List.generate(
        moods.length,
        (index) {
          final selected = selectedMood == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedMood = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? freshMint
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? darkGreen
                        : paleMint,
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    if (selected)
                      BoxShadow(
                        color: darkGreen.withOpacity(0.07),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 220),
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withOpacity(0.65)
                            : paleMint,
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          moodEmojis[index],
                          style: const TextStyle(
                            fontSize: 21,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Text(
                        moods[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: forestText,
                        ),
                      ),
                    ),

                    AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 220),
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? darkGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? darkGreen
                              : mutedText.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // SLIDER CARD
  // ==========================================================

  Widget _sliderCard({
    required IconData icon,
    required String title,
    required String description,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String leftText,
    required String rightText,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        17,
        17,
        17,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: paleMint,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: paleMint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: darkGreen,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: forestText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: darkGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: darkGreen,
              inactiveTrackColor: paleMint,
              thumbColor: darkGreen,
              overlayColor: darkGreen.withOpacity(0.09),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 9,
              ),
              overlayShape:
                  const RoundSliderOverlayShape(
                overlayRadius: 17,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leftText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: mutedText,
                  ),
                ),
                Text(
                  rightText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: mutedText,
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
  // SOCIAL SELECTOR
  // ==========================================================

  Widget _socialSelector() {
    return Column(
      children: List.generate(
        socialOptions.length,
        (index) {
          final selected = selectedSocial == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedSocial = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? paleMint
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? darkGreen
                        : paleMint,
                    width: selected ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      socialEmojis[index],
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Text(
                        socialOptions[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: forestText,
                        ),
                      ),
                    ),

                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selected
                          ? darkGreen
                          : mutedText.withOpacity(0.28),
                      size: 23,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


// ==========================================================
// REFLECTION
// ==========================================================

Widget _reflectionField() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      border: Border.all(
        color: paleMint,
      ),
    ),
    child: Stack(
      children: [
        TextField(
          controller: reflectionController,

          // Proper multiline text input
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,

          // Allows the text to flow normally across the field
          minLines: 6,
          maxLines: 6,

          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.top,

          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: forestText,
          ),

          decoration: const InputDecoration(
            hintText:
                'What is on your mind right now?\n\n'
                'It can be a thought, a feeling, a moment...',
            hintStyle: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: mutedText,
            ),

            border: InputBorder.none,

            // Extra right space so text never overlaps the icon
            contentPadding: EdgeInsets.fromLTRB(
              18,
              18,
              65,
              18,
            ),
          ),
        ),

        // Edit icon placed on top instead of using suffixIcon
        Positioned(
          top: 14,
          right: 14,
          child: IgnorePointer(
            child: Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: paleMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: darkGreen,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  // ==========================================================
  // ANALYSIS SELECTOR
  // ==========================================================

  Widget _analysisSelector() {
    return Column(
      children: [
        _analysisOption(
          value: 'gemini',
          icon: Icons.auto_awesome_rounded,
          title: 'Gemini AI',
          subtitle:
              'Gemini interprets the emotion and creates your reflection.',
        ),

        const SizedBox(height: 10),

        _analysisOption(
          value: 'trained_model',
          icon: Icons.hub_rounded,
          title: 'Trained Model + Gemini',
          subtitle:
              'A trained model detects emotion while Gemini creates the reflection.',
        ),
      ],
    );
  }

  Widget _analysisOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = analysisMode == value;

    return GestureDetector(
      onTap: () {
        setState(() => analysisMode = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? freshMint
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? darkGreen
                : paleMint,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: darkGreen.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.6)
                    : paleMint,
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: darkGreen,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: forestText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? darkGreen
                  : mutedText.withOpacity(0.3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SAVE BUTTON
  // ==========================================================

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isSaving ? null : analyzeMood,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          disabledBackgroundColor:
              darkGreen.withOpacity(0.55),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          shadowColor: darkGreen.withOpacity(0.18),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSaving
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  key: ValueKey('button'),
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      'Save & understand my mood',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 9),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),

    );
  }
}
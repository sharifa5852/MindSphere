import 'package:flutter/material.dart';

class MoodCheckInPage extends StatefulWidget {
  const MoodCheckInPage({super.key});

  @override
  State<MoodCheckInPage> createState() => _MoodCheckInPageState();
}

class _MoodCheckInPageState extends State<MoodCheckInPage> {
  // Selected answers
  int selectedMood = -1;
  int selectedSocial = -1;

  // Slider values
  double intensity = 50;
  double energy = 50;
  double sleep = 7;

  // Text reflection
  final TextEditingController reflectionController = TextEditingController();

  // Mood options
  final List<String> moods = [
    '😊 Very positive',
    '🙂 Positive',
    '😐 Neutral',
    '😔 Negative',
    '😣 Very negative',
  ];

  // Social connection options
  final List<String> socialOptions = [
    '😊 Connected',
    '😐 Normal',
    '😔 A little withdrawn',
    '😣 Very withdrawn',
  ];

  @override
  void dispose() {
    reflectionController.dispose();
    super.dispose();
  }

  // This will later be replaced/connected with your AI model API.
  void analyzeMood() {
    if (selectedMood == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your current mood first.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmotionResultPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        foregroundColor: const Color(0xFF403E38),
        title: const Text(
          'Mood check-in',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          // ------------------------------------------------
          // INTRODUCTION
          // ------------------------------------------------

          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF403E38),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'A few quick questions will help MindSphere understand your emotional state.',
            style: TextStyle(
              color: Color(0xFF827C73),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // ------------------------------------------------
          // MOOD QUESTION
          // ------------------------------------------------

          const Text(
            'How would you describe your current mood?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF403E38),
            ),
          ),

          const SizedBox(height: 10),

          _card(
            child: Column(
              children: List.generate(
                moods.length,
                (index) {
                  return RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    value: index,
                    groupValue: selectedMood,
                    activeColor: const Color(0xFF56745B),
                    title: Text(
                      moods[index],
                      style: const TextStyle(
                        color: Color(0xFF403E38),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedMood = value!;
                      });
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // EMOTION INTENSITY
          // ------------------------------------------------

          _sliderCard(
            title: 'How intense does this feeling feel?',
            valueText: '${intensity.round()}%',
            value: intensity,
            min: 0,
            max: 100,
            divisions: 20,
            leftText: 'Low',
            rightText: 'High',
            onChanged: (value) {
              setState(() {
                intensity = value;
              });
            },
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------
          // ENERGY
          // ------------------------------------------------

          _sliderCard(
            title: 'How is your energy today?',
            valueText: '${energy.round()}%',
            value: energy,
            min: 0,
            max: 100,
            divisions: 20,
            leftText: 'Low',
            rightText: 'High',
            onChanged: (value) {
              setState(() {
                energy = value;
              });
            },
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------
          // SLEEP
          // ------------------------------------------------

          _sliderCard(
            title: 'How did you sleep last night?',
            valueText: '${sleep.round()} hours',
            value: sleep,
            min: 0,
            max: 12,
            divisions: 12,
            leftText: '0 hours',
            rightText: '12 hours',
            onChanged: (value) {
              setState(() {
                sleep = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------
          // SOCIAL CONNECTION
          // ------------------------------------------------

          const Text(
            'How connected do you feel to others today?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF403E38),
            ),
          ),

          const SizedBox(height: 10),

          _card(
            child: Column(
              children: List.generate(
                socialOptions.length,
                (index) {
                  return RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    value: index,
                    groupValue: selectedSocial,
                    activeColor: const Color(0xFF56745B),
                    title: Text(
                      socialOptions[index],
                      style: const TextStyle(
                        color: Color(0xFF403E38),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedSocial = value!;
                      });
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------
          // TEXT REFLECTION
          // ------------------------------------------------

          const Text(
            'Anything you would like to share?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF403E38),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: reflectionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Write a few words about how you are feeling...',
              hintStyle: const TextStyle(
                color: Color(0xFF827C73),
              ),
              filled: true,
              fillColor: const Color(0xFFFFFDFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE9E3D9),
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ------------------------------------------------
          // SAVE & ANALYZE BUTTON
          // ------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: analyzeMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56745B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Save & analyze ✦',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Your answers are used to provide an emotional reflection.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF827C73),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // REUSABLE CARD
  // ======================================================

  Widget _card({
    required Widget child,
    Color color = const Color(0xFFFFFDFA),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE9E3D9),
        ),
      ),
      child: child,
    );
  }

  // ======================================================
  // REUSABLE SLIDER CARD
  // ======================================================

  Widget _sliderCard({
    required String title,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String leftText,
    required String rightText,
    required ValueChanged<double> onChanged,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF403E38),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            valueText,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Color(0xFF56745B),
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: const Color(0xFF56745B),
            inactiveColor: const Color(0xFFDCE6D8),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leftText,
                style: const TextStyle(
                  color: Color(0xFF827C73),
                ),
              ),
              Text(
                rightText,
                style: const TextStyle(
                  color: Color(0xFF827C73),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// EMOTION RESULT PAGE
// ==========================================================

class EmotionResultPage extends StatelessWidget {
  const EmotionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        foregroundColor: const Color(0xFF403E38),
        title: const Text(
          'Your reflection',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        children: [
          const SizedBox(height: 5),

          // ------------------------------------------------
          // TOP ICON
          // ------------------------------------------------

          const Center(
            child: Text(
              '✦',
              style: TextStyle(
                fontSize: 42,
                color: Color(0xFF56745B),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              'MOST LIKELY EMOTION',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w800,
                color: Color(0xFF56745B),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Center(
            child: Text(
              '😣',
              style: TextStyle(
                fontSize: 55,
              ),
            ),
          ),

          const SizedBox(height: 4),

          const Center(
            child: Text(
              'Nervousness',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF403E38),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ------------------------------------------------
          // CONFIDENCE
          // ------------------------------------------------

          _resultCard(
            color: const Color(0xFFEEF5EB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Model confidence',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF827C73),
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '84%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF56745B),
                      ),
                    ),
                    Text(
                      'High confidence',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF56745B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.84,
                    minHeight: 9,
                    color: Color(0xFF56745B),
                    backgroundColor: Color(0xFFDCE6D8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ------------------------------------------------
          // MODEL EXPLANATION
          // ------------------------------------------------

          _resultCard(
            color: const Color(0xFFE7E0EF),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✦ What MindSphere noticed',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF685D79),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your answers suggest language associated with nervousness.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF403E38),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------
          // OTHER EMOTIONS
          // ------------------------------------------------

          const Text(
            'Other emotions detected',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF403E38),
            ),
          ),

          const SizedBox(height: 10),

          _resultCard(
            child: Column(
              children: [
                _emotionRow(
                  emoji: '😣',
                  name: 'Nervousness',
                  percentage: '84%',
                  progress: 0.84,
                ),
                const Divider(height: 24),
                _emotionRow(
                  emoji: '😨',
                  name: 'Fear',
                  percentage: '9%',
                  progress: 0.09,
                ),
                const Divider(height: 24),
                _emotionRow(
                  emoji: '😔',
                  name: 'Sadness',
                  percentage: '4%',
                  progress: 0.04,
                ),
                const Divider(height: 24),
                _emotionRow(
                  emoji: '😐',
                  name: 'Neutral',
                  percentage: '3%',
                  progress: 0.03,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // DISCLAIMER
          // ------------------------------------------------

          _resultCard(
            color: const Color(0xFFF6EDCC),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌿',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is an emotional reflection, not a medical diagnosis.',
                    style: TextStyle(
                      color: Color(0xFF827C73),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ------------------------------------------------
          // DONE BUTTON
          // ------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56745B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // RESULT CARD
  // ======================================================

  Widget _resultCard({
    required Widget child,
    Color color = const Color(0xFFFFFDFA),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE9E3D9),
        ),
      ),
      child: child,
    );
  }

  // ======================================================
  // EMOTION ROW
  // ======================================================

  Widget _emotionRow({
    required String emoji,
    required String name,
    required String percentage,
    required double progress,
  }) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(
            fontSize: 25,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF403E38),
                    ),
                  ),
                  Text(
                    percentage,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF56745B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: const Color(0xFF56745B),
                  backgroundColor: const Color(0xFFE8E4DC),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

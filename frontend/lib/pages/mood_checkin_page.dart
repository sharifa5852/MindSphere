import 'package:flutter/material.dart';

import 'mood_result_page.dart';
import '../services/api_service.dart';

class MoodCheckInPage extends StatefulWidget {
  const MoodCheckInPage({super.key});

  @override
  State<MoodCheckInPage> createState() => _MoodCheckInPageState();
}

class _MoodCheckInPageState extends State<MoodCheckInPage> {
  int selectedMood = -1;
  int selectedSocial = -1;
  bool _isSaving = false;

  double intensity = 50;
  double energy = 50;
  double sleep = 7;

  String analysisMode = 'gemini';

  final TextEditingController reflectionController = TextEditingController();

  final List<String> moods = [
    '😊 Very positive',
    '🙂 Positive',
    '😐 Neutral',
    '😔 Negative',
    '😣 Very negative',
  ];

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

  Future<void> analyzeMood() async {
    if (selectedMood == -1 || selectedSocial == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood and social connection.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final moodValue = selectedMood + 1;
    final stressValue = ((intensity / 25).round() + 1).clamp(1, 5).toInt();
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

      final savedEntry = Map<String, dynamic>.from(saved['moodEntry'] as Map? ?? {});
      final entryId = savedEntry['_id'] as String?;

      String? emotion;
      double? confidence;
      List<EmotionScore> otherEmotions = const [];
      String? insight;
      String? modeUsed;

      if (entryId != null) {
        try {
          final analysisResponse = await ApiService.analyzeMoodEntry(entryId, mode: analysisMode);
          final analysis = Map<String, dynamic>.from(analysisResponse['analysis'] as Map? ?? {});
          emotion = analysis['emotion'] as String?;
          confidence = (analysis['confidence'] as num?)?.toDouble();
          insight = analysis['insight'] as String?;
          modeUsed = analysisResponse['mode'] as String?;
          final otherList = analysis['otherEmotions'] as List<dynamic>? ?? const [];
          otherEmotions = otherList
              .map((item) => Map<String, dynamic>.from(item as Map))
              .map((item) => EmotionScore(
                    label: item['label'] as String? ?? '',
                    score: (item['score'] as num?)?.toDouble() ?? 0,
                  ))
              .toList();
        } catch (_) {
          // The check-in itself is safely saved above; only the emotion
          // analysis could not be reached.
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
        SnackBar(content: Text(ApiService.readableError(error))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        foregroundColor: const Color(0xFF403E38),
        title: const Text('Mood check-in', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
          ),
          const SizedBox(height: 8),
          const Text(
            'A few quick questions will help MindSphere understand your emotional state.',
            style: TextStyle(color: Color(0xFF827C73), height: 1.4),
          ),
          const SizedBox(height: 24),
          const Text(
            'How would you describe your current mood?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
          ),
          const SizedBox(height: 10),
          _card(
            child: Column(
              children: List.generate(moods.length, (index) {
                return RadioListTile<int>(
                  contentPadding: EdgeInsets.zero,
                  value: index,
                  groupValue: selectedMood,
                  activeColor: const Color(0xFF56745B),
                  title: Text(moods[index], style: const TextStyle(color: Color(0xFF403E38))),
                  onChanged: (value) => setState(() => selectedMood = value!),
                );
              }),
            ),
          ),
          const SizedBox(height: 18),
          _sliderCard(
            title: 'How stressed do you feel today?',
            valueText: '${intensity.round()}%',
            value: intensity,
            min: 0,
            max: 100,
            divisions: 20,
            leftText: 'Low',
            rightText: 'High',
            onChanged: (value) => setState(() => intensity = value),
          ),
          const SizedBox(height: 14),
          _sliderCard(
            title: 'How is your energy today?',
            valueText: '${energy.round()}%',
            value: energy,
            min: 0,
            max: 100,
            divisions: 20,
            leftText: 'Low',
            rightText: 'High',
            onChanged: (value) => setState(() => energy = value),
          ),
          const SizedBox(height: 14),
          _sliderCard(
            title: 'How did you sleep last night?',
            valueText: '${sleep.round()} hours',
            value: sleep,
            min: 0,
            max: 12,
            divisions: 12,
            leftText: '0 hours',
            rightText: '12 hours',
            onChanged: (value) => setState(() => sleep = value),
          ),
          const SizedBox(height: 20),
          const Text(
            'How connected do you feel to others today?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
          ),
          const SizedBox(height: 10),
          _card(
            child: Column(
              children: List.generate(socialOptions.length, (index) {
                return RadioListTile<int>(
                  contentPadding: EdgeInsets.zero,
                  value: index,
                  groupValue: selectedSocial,
                  activeColor: const Color(0xFF56745B),
                  title: Text(socialOptions[index], style: const TextStyle(color: Color(0xFF403E38))),
                  onChanged: (value) => setState(() => selectedSocial = value!),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Anything you would like to share?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: reflectionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Write a few words about how you are feeling...',
              hintStyle: const TextStyle(color: Color(0xFF827C73)),
              filled: true,
              fillColor: const Color(0xFFFFFDFA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE9E3D9)),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ------------------------------------------------
          // ANALYSIS METHOD SELECTOR
          // ------------------------------------------------
          const Text(
            'Choose analysis method',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
          ),
          const SizedBox(height: 10),
          _card(
            child: Column(
              children: [
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: 'gemini',
                  groupValue: analysisMode,
                  activeColor: const Color(0xFF56745B),
                  title: const Text('Gemini AI', style: TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.w700)),
                  subtitle: const Text(
                    'Gemini detects the emotion and writes the reflection.',
                    style: TextStyle(color: Color(0xFF827C73), fontSize: 12),
                  ),
                  onChanged: (value) => setState(() => analysisMode = value!),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: 'trained_model',
                  groupValue: analysisMode,
                  activeColor: const Color(0xFF56745B),
                  title: const Text('Trained Model + Gemini', style: TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.w700)),
                  subtitle: const Text(
                    'A trained emotion-detection model finds the emotion; Gemini writes the reflection.',
                    style: TextStyle(color: Color(0xFF827C73), fontSize: 12),
                  ),
                  onChanged: (value) => setState(() => analysisMode = value!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : analyzeMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56745B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isSaving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Save & analyze ✦', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your answers are used to provide an emotional reflection.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF827C73)),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, Color color = const Color(0xFFFFFDFA)}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9E3D9)),
      ),
      child: child,
    );
  }

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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF403E38))),
          const SizedBox(height: 5),
          Text(valueText, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Color(0xFF56745B))),
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
              Text(leftText, style: const TextStyle(color: Color(0xFF827C73))),
              Text(rightText, style: const TextStyle(color: Color(0xFF827C73))),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class EmotionScore {
  const EmotionScore({required this.label, required this.score});
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
  if (value.contains('calm') || value.contains('content') || value.contains('relax')) return '😌';
  if (value.contains('happy') || value.contains('joy') || value.contains('positive') || value.contains('amus')) return '😊';
  if (value.contains('sad') || value.contains('down') || value.contains('griev')) return '😔';
  if (value.contains('anx') || value.contains('nerv') || value.contains('worry')) return '😣';
  if (value.contains('fear') || value.contains('afraid')) return '😨';
  if (value.contains('anger') || value.contains('frustrat') || value.contains('irritat') || value.contains('annoy')) return '😠';
  if (value.contains('tired') || value.contains('overwhelm') || value.contains('exhaust')) return '😞';
  if (value.contains('neutral')) return '😐';
  if (value.contains('surpris') || value.contains('curio')) return '😲';
  return '🌿';
}

String _modeLabel(String? mode) {
  switch (mode) {
    case 'trained_model':
      return 'Analyzed with Trained Model + Gemini';
    case 'gemini':
      return 'Analyzed with Gemini AI';
    case 'fallback':
      return 'Analyzed with a general reflection (AI unavailable)';
    default:
      return '';
  }
}

class MoodResultPage extends StatelessWidget {
  const MoodResultPage({super.key, required this.result});

  final MoodCheckInResult result;

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
        return String.fromCharCode(0x1F60A);
      case 2:
        return String.fromCharCode(0x1F642);
      case 3:
        return String.fromCharCode(0x1F610);
      case 4:
        return String.fromCharCode(0x1F614);
      case 5:
        return String.fromCharCode(0x1F623);
      default:
        return String.fromCharCode(0x1F33F);
    }
  }

  String get _stressLabel {
    const labels = ['Low', 'Low', 'Moderate', 'High', 'Very high'];
    return labels[result.stress.clamp(1, 5).toInt() - 1];
  }

  String get _socialLabel {
    const labels = ['Connected', 'Normally connected', 'A little withdrawn', 'Very withdrawn'];
    return labels[result.socialConnection.clamp(1, 4).toInt() - 1];
  }

  String get _reflection {
    final parts = <String>[];
    if (result.mood >= 4) {
      parts.add('Today sounds like it may be feeling difficult.');
    } else if (result.mood <= 2) {
      parts.add('You reported a positive mood today.');
    } else {
      parts.add('You reported a more neutral mood today.');
    }
    if (result.stress >= 4) {
      parts.add('Your stress level was high, so a small pause or a calming activity may help.');
    } else if (result.energy <= 30) {
      parts.add('Your energy was low; if you can, give yourself permission to rest and keep things gentle.');
    } else if (result.sleep < 6) {
      parts.add('You reported less than six hours of sleep, so extra care and rest may be useful.');
    } else if (result.socialConnection >= 3) {
      parts.add('You also felt somewhat withdrawn. Reaching out to someone you trust may help if that feels right.');
    } else {
      parts.add('Keep noticing what supports your wellbeing as your day continues.');
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final hasEmotionAnalysis = result.emotion != null && result.emotion!.trim().isNotEmpty;
    final confidencePercent = ((result.confidence ?? 0) * 100).round();
    final modeLabel = _modeLabel(result.analysisModeUsed);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        foregroundColor: const Color(0xFF403E38),
        title: const Text('Your reflection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        children: [
          const Center(
            child: Text(
              'CHECK-IN COMPLETE',
              style: TextStyle(fontSize: 11, letterSpacing: 1.3, fontWeight: FontWeight.w800, color: Color(0xFF56745B)),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(_moodEmojiText, style: const TextStyle(fontSize: 56))),
          const SizedBox(height: 6),
          Center(
            child: Text(
              _moodLabel,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
            ),
          ),
          const SizedBox(height: 24),
          if (hasEmotionAnalysis) ...[
            const Center(
              child: Text(
                'MOST LIKELY EMOTION',
                style: TextStyle(fontSize: 11, letterSpacing: 1.3, fontWeight: FontWeight.w800, color: Color(0xFF56745B)),
              ),
            ),
            const SizedBox(height: 10),
            Center(child: Text(_emojiForEmotion(result.emotion), style: const TextStyle(fontSize: 48))),
            const SizedBox(height: 4),
            Center(
              child: Text(
                result.emotion!,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
              ),
            ),
            if (modeLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  modeLabel,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF827C73), fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _ResultCard(
              color: const Color(0xFFEEF5EB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Model confidence', style: TextStyle(fontSize: 13, color: Color(0xFF827C73))),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$confidencePercent%',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF56745B)),
                      ),
                      Text(
                        confidencePercent >= 70
                            ? 'High confidence'
                            : confidencePercent >= 40
                                ? 'Moderate confidence'
                                : 'Low confidence',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF56745B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (result.confidence ?? 0).clamp(0, 1).toDouble(),
                      minHeight: 9,
                      color: const Color(0xFF56745B),
                      backgroundColor: const Color(0xFFDCE6D8),
                    ),
                  ),
                ],
              ),
            ),
            if (result.otherEmotions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Other emotions detected',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
              ),
              const SizedBox(height: 10),
              _ResultCard(
                child: Column(
                  children: [
                    for (var i = 0; i < result.otherEmotions.length; i++) ...[
                      if (i > 0) const Divider(height: 24),
                      _emotionRow(result.otherEmotions[i]),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
          _ResultCard(
            color: const Color(0xFFE7E0EF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A gentle reflection',
                  style: TextStyle(fontSize: 12, letterSpacing: 0.8, fontWeight: FontWeight.w800, color: Color(0xFF685D79)),
                ),
                const SizedBox(height: 8),
                Text(
                  hasEmotionAnalysis && result.insight != null && result.insight!.trim().isNotEmpty
                      ? result.insight!
                      : _reflection,
                  style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: Color(0xFF403E38)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your check-in',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
          ),
          const SizedBox(height: 10),
          _ResultCard(
            child: Column(
              children: [
                _detailRow('Stress', _stressLabel),
                const Divider(height: 24),
                _detailRow('Energy', '${result.energy}%'),
                const Divider(height: 24),
                _detailRow('Sleep', '${result.sleep} hours'),
                const Divider(height: 24),
                _detailRow('Social connection', _socialLabel),
              ],
            ),
          ),
          if (result.note.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _ResultCard(
              color: const Color(0xFFEEF5EB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What you shared', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF56745B))),
                  const SizedBox(height: 8),
                  Text(result.note.trim(), style: const TextStyle(height: 1.4, color: Color(0xFF403E38))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          const _ResultCard(
            color: Color(0xFFF6EDCC),
            child: Text(
              'This reflection is based on what you shared today. It supports self-awareness and is not a medical diagnosis.',
              style: TextStyle(color: Color(0xFF827C73), height: 1.4),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56745B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Done', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF827C73))),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF403E38)),
          ),
        ),
      ],
    );
  }

  Widget _emotionRow(EmotionScore emotionScore) {
    final percent = (emotionScore.score.clamp(0, 1) * 100).round();
    return Row(
      children: [
        Text(_emojiForEmotion(emotionScore.label), style: const TextStyle(fontSize: 25)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emotionScore.label, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF403E38))),
                  Text('$percent%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF56745B))),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: emotionScore.score.clamp(0, 1).toDouble(),
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.child, this.color = const Color(0xFFFFFDFA)});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
}
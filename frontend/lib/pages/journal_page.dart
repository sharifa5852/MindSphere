import 'package:flutter/material.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  // Controller for the journal text box
  final TextEditingController journalController = TextEditingController();

  // Controls whether the Mood Lens is shown
  bool showAnalysis = false;

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  // Called when the user presses Save & Reflect
  void analyzeJournal() {
    if (journalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something first.'),
        ),
      );

      return;
    }

    setState(() {
      showAnalysis = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text(
          'Journal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF403E38),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ------------------------------------
          // PAGE TITLE
          // ------------------------------------

          const Text(
            'How was your day?',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF403E38),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Write freely about your thoughts, feelings, '
            'or anything that happened today.',
            style: TextStyle(
              color: Color(0xFF827C73),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------
          // JOURNAL TEXT BOX
          // ------------------------------------

          TextField(
            controller: journalController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Write whatever is on your mind...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFFE9E3D9),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ------------------------------------
          // SAVE & REFLECT BUTTON
          // ------------------------------------

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: analyzeJournal,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF56745B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                showAnalysis ? 'Reflection Ready ✓' : 'Save & Reflect',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ------------------------------------
          // MOOD LENS
          // ------------------------------------

          if (showAnalysis) ...[
            const SizedBox(height: 20),
            const MoodLensCard(),
          ],

          const SizedBox(height: 25),

          // ------------------------------------
          // RECENT ENTRIES
          // ------------------------------------

          const Text(
            'Recent Entries',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE9E3D9),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'August 10',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '"Today was pretty stressful, '
                  'but I managed to take a walk."',
                  style: TextStyle(
                    color: Color(0xFF827C73),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 10),
                MoodTag(
                  text: '😣 Stressed',
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ======================================================
// MOOD LENS CARD
// ======================================================

class MoodLensCard extends StatelessWidget {
  const MoodLensCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF5EB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDCE6D8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------
          // HEADER
          // ------------------------------------

          const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFA8C3A0),
                child: Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF56745B),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Journal Mood Lens',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Emotion analysis',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF827C73),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ------------------------------------
          // EMOTIONS
          // ------------------------------------

          const Wrap(
            spacing: 8,
            children: [
              MoodTag(
                text: '😣 Stressed',
                active: true,
              ),
              MoodTag(
                text: '😐 Neutral',
              ),
              MoodTag(
                text: '🌿 Calm',
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ------------------------------------
          // CONFIDENCE
          // ------------------------------------

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Model confidence',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF827C73),
                ),
              ),
              Text(
                '84%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          const LinearProgressIndicator(
            value: 0.84,
            color: Color(0xFF56745B),
            backgroundColor: Color(0xFFDCE6D8),
            minHeight: 7,
          ),

          const SizedBox(height: 18),

          // ------------------------------------
          // REFLECTION
          // ------------------------------------

          const Text(
            'A gentle reflection',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Your writing may reflect academic stress. '
            'Taking a short break or talking with someone '
            'you trust may help.',
            style: TextStyle(
              color: Color(0xFF827C73),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          // ------------------------------------
          // AI BUTTON
          // ------------------------------------

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Breathing exercise will be connected later.',
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.air,
              ),
              label: const Text(
                'Try a 2-minute breathing exercise',
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Emotional support only — not a medical diagnosis.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF827C73),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// MOOD TAG
// ======================================================

class MoodTag extends StatelessWidget {
  final String text;

  final bool active;

  const MoodTag({
    super.key,
    required this.text,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD9EAD5) : Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? const Color(0xFF56745B) : const Color(0xFF403E38),
        ),
      ),
    );
  }
}

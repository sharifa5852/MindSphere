import 'package:flutter/material.dart';
import 'assessment_page.dart';

class AssessmentListPage extends StatelessWidget {
  const AssessmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text(
          'Assessments',
          style: TextStyle(
            color: Color(0xFF403E38),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Understand your wellbeing',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF403E38),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Take a short check-in to reflect on how '
            'you have been feeling recently.',
            style: TextStyle(
              color: Color(0xFF827C73),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 22),

          // Stress
          AssessmentCard(
            icon: '🌿',
            title: 'Stress Assessment',
            description: 'Reflect on your recent stress levels.',
            color: const Color(0xFFDDEBD9),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssessmentPage(
                    title: 'Stress Assessment',
                    type: 'stress',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Anxiety
          AssessmentCard(
            icon: '💭',
            title: 'Anxiety Check',
            description: 'Reflect on recent worries and anxiety.',
            color: const Color(0xFFE7E0EF),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssessmentPage(
                    title: 'Anxiety Check',
                    type: 'anxiety',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Mood
          AssessmentCard(
            icon: '🌙',
            title: 'Mood Check',
            description: 'Reflect on your recent mood and energy.',
            color: const Color(0xFFF1DCDD),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssessmentPage(
                    title: 'Mood Check',
                    type: 'mood',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          const Text(
            'Previous Results',
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
                  'Stress — Moderate',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'August 9 · Previous check-in',
                  style: TextStyle(
                    color: Color(0xFF827C73),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// ASSESSMENT CARD
// ======================================================

class AssessmentCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onPressed;

  const AssessmentCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF827C73),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'About 2 minutes',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF827C73),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF56745B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

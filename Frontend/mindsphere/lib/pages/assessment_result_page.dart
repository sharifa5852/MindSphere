import 'package:flutter/material.dart';

class AssessmentResultPage extends StatelessWidget {
  final String title;
  final String type;
  final double average;

  const AssessmentResultPage({
    super.key,
    required this.title,
    required this.type,
    required this.average,
  });

  String get level {
    if (average < 1) {
      return 'Low';
    }

    if (average < 2) {
      return 'Moderate';
    }

    return 'Elevated';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text(
          'Your Reflection',
          style: TextStyle(
            color: Color(0xFF403E38),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          const Center(
            child: Text(
              '🌿',
              style: TextStyle(
                fontSize: 50,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                color: Color(0xFF56745B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              level,
              style: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Color(0xFF56745B),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'This result is a supportive reflection '
            'based on your answers. It is not a medical diagnosis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF827C73),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 25),

          // Next step card

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE9E3D9),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A small next step 🌱',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Consider taking a short break, '
                  'trying a breathing exercise, or '
                  'talking with someone you trust.',
                  style: TextStyle(
                    color: Color(0xFF827C73),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Back button

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Back to Assessments',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

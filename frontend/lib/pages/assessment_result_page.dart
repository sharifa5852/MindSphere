// import 'package:flutter/material.dart';

// import 'professional_support_page.dart';

// class AssessmentResultPage extends StatelessWidget {
//   const AssessmentResultPage({super.key, required this.title, required this.assessment, required this.disclaimer, this.supportMessage});
//   final String title;
//   final Map<String, dynamic> assessment;
//   final String disclaimer;
//   final String? supportMessage;

//   @override
//   Widget build(BuildContext context) {
//     final result = Map<String, dynamic>.from(assessment['result'] as Map? ?? {});
//     final level = (result['level'] as String? ?? 'not available').replaceAll('_', ' ');
//     final shouldShowSupport = result['considerProfessionalSupport'] == true || result['needsSupportPrompt'] == true;
//     return Scaffold(backgroundColor: const Color(0xFFFAF8F3), appBar: AppBar(backgroundColor: const Color(0xFFFAF8F3), elevation: 0, title: const Text('Your Reflection', style: TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.bold))), body: ListView(padding: const EdgeInsets.all(20), children: [
//       const SizedBox(height: 20), const Center(child: Icon(Icons.self_improvement, size: 50, color: Color(0xFF56745B))), const SizedBox(height: 12),
//       Center(child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 1.2, color: Color(0xFF56745B), fontWeight: FontWeight.bold))), const SizedBox(height: 8),
//       Center(child: Text(level, textAlign: TextAlign.center, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFF56745B))), const SizedBox(height: 10),
//       Center(child: Text('Score: ${assessment['score'] ?? '-'}', style: const TextStyle(color: Color(0xFF827C73))), const SizedBox(height: 14),
//       Text(disclaimer, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF827C73), height: 1.4)), const SizedBox(height: 25),
//       _card(color: shouldShowSupport ? const Color(0xFFF6EDCC) : Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(shouldShowSupport ? 'Support may be helpful' : 'A small next step', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 8),
//         Text(supportMessage ?? 'Consider taking a short break, trying a breathing exercise, or talking with someone you trust.', style: const TextStyle(color: Color(0xFF827C73), height: 1.4)),
//       ])),
//       if (shouldShowSupport) ...[const SizedBox(height: 16), SizedBox(height: 52, child: FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalSupportPage())), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF56745B)), child: const Text('Explore professional support')))],
//       const SizedBox(height: 20), SizedBox(height: 52, child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Assessments'))),
//     ]));
//   }

//   Widget _card({required Widget child, Color color = Colors.white}) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE9E3D9))), child: child);
// }
import 'package:flutter/material.dart';

import 'professional_support_page.dart';

class AssessmentResultPage extends StatelessWidget {
  const AssessmentResultPage({
    super.key,
    required this.title,
    required this.assessment,
    required this.disclaimer,
    this.supportMessage,
  });

  final String title;
  final Map<String, dynamic> assessment;
  final String disclaimer;
  final String? supportMessage;

  @override
  Widget build(BuildContext context) {
    final result =
        Map<String, dynamic>.from(assessment['result'] as Map? ?? {});

    final level =
        (result['level'] as String? ?? 'not available').replaceAll('_', ' ');

    final shouldShowSupport =
        result['considerProfessionalSupport'] == true ||
        result['needsSupportPrompt'] == true;

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
            child: Icon(
              Icons.self_improvement,
              size: 50,
              color: Color(0xFF56745B),
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Color(0xFF56745B),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              'Score: ${assessment['score'] ?? '-'}',
              style: const TextStyle(
                color: Color(0xFF827C73),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            disclaimer,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF827C73),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 25),

          _card(
            color: shouldShowSupport
                ? const Color(0xFFF6EDCC)
                : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shouldShowSupport
                      ? 'Support may be helpful'
                      : 'A small next step',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  supportMessage ??
                      'Consider taking a short break, trying a breathing exercise, or talking with someone you trust.',
                  style: const TextStyle(
                    color: Color(0xFF827C73),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          if (shouldShowSupport) ...[
            const SizedBox(height: 16),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfessionalSupportPage(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF56745B),
                ),
                child: const Text('Explore professional support'),
              ),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Assessments'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    Color color = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
}
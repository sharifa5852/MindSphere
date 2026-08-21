import 'package:flutter/material.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text(
          'Your Insights',
          style: TextStyle(
            color: Color(0xFF403E38),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ------------------------------------
          // HEADER
          // ------------------------------------

          const Text(
            'THIS WEEK',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: Color(0xFF56745B),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'A gentle look at your patterns.',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF403E38),
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------
          // MOOD CARD
          // ------------------------------------

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE9E3D9),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mood',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 15),

                // Simple mood chart
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: MoodChartPainter(),
                    child: Container(),
                  ),
                ),

                const SizedBox(height: 8),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('M'),
                    Text('T'),
                    Text('W'),
                    Text('T'),
                    Text('F'),
                    Text('S'),
                    Text('S'),
                  ],
                ),

                const SizedBox(height: 18),

                const Text(
                  '78%',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF56745B),
                  ),
                ),

                const Text(
                  'Average mood',
                  style: TextStyle(
                    color: Color(0xFF827C73),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // ------------------------------------
          // STATS
          // ------------------------------------

          Row(
            children: [
              Expanded(
                child: InsightCard(
                  title: 'Stress',
                  value: '↓ 15%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InsightCard(
                  title: 'Sleep',
                  value: '7h 20m',
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: InsightCard(
                  title: 'Check-ins',
                  value: '5',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InsightCard(
                  title: 'Journal',
                  value: '4 entries',
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ------------------------------------
          // WEEKLY REFLECTION
          // ------------------------------------

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE7E0EF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✦ WEEKLY REFLECTION',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    color: Color(0xFF685D79),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'You experienced slightly higher '
                  'stress around the middle of the week, '
                  'but your overall mood improved.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // ------------------------------------
          // SMALL REMINDER
          // ------------------------------------

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EDCC),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Small reminder 🌱',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your wellbeing is a process, not a score. '
                  'Keep checking in with yourself.',
                  style: TextStyle(
                    color: Color(0xFF827C73),
                    height: 1.4,
                  ),
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
// INSIGHT CARD
// ======================================================

class InsightCard extends StatelessWidget {
  final String title;
  final String value;

  const InsightCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE9E3D9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF827C73),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF56745B),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// MOOD CHART
// ======================================================

class MoodChartPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF56745B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(
      0,
      size.height * 0.75,
    );

    path.cubicTo(
      size.width * 0.12,
      size.height * 0.70,
      size.width * 0.18,
      size.height * 0.55,
      size.width * 0.28,
      size.height * 0.60,
    );

    path.cubicTo(
      size.width * 0.38,
      size.height * 0.68,
      size.width * 0.45,
      size.height * 0.30,
      size.width * 0.55,
      size.height * 0.45,
    );

    path.cubicTo(
      size.width * 0.65,
      size.height * 0.55,
      size.width * 0.75,
      size.height * 0.40,
      size.width,
      size.height * 0.15,
    );

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

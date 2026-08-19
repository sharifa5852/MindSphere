import 'package:flutter/material.dart';

class MoodCheckInPage extends StatefulWidget {
  const MoodCheckInPage({super.key});

  @override
  State<MoodCheckInPage> createState() => _MoodCheckInPageState();
}

class _MoodCheckInPageState extends State<MoodCheckInPage> {
  int selectedMood = 1;

  double stress = 40;

  double sleep = 7;

  final noteController = TextEditingController();

  final List<String> moods = [
    '😄',
    '😊',
    '😐',
    '😔',
    '😣',
  ];

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void saveCheckIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your check-in has been saved ✓'),
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
        title: const Text(
          'Mood Check-In',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF403E38),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // -------------------------------
          // TITLE
          // -------------------------------

          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF403E38),
            ),
          ),

          const SizedBox(height: 22),

          // -------------------------------
          // MOOD EMOJIS
          // -------------------------------

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              moods.length,
              (index) {
                final isSelected = selectedMood == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = index;
                    });
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1.0 : 0.45,
                    child: Text(
                      moods[index],
                      style: TextStyle(
                        fontSize: isSelected ? 38 : 30,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Great',
                style: TextStyle(
                  color: Color(0xFF827C73),
                ),
              ),
              Text(
                'Okay',
                style: TextStyle(
                  color: Color(0xFF827C73),
                ),
              ),
              Text(
                'Low',
                style: TextStyle(
                  color: Color(0xFF827C73),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // -------------------------------
          // STRESS
          // -------------------------------

          Container(
            padding: const EdgeInsets.all(18),
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
                const Text(
                  'How stressed do you feel?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Slider(
                  value: stress,
                  min: 0,
                  max: 100,
                  activeColor: const Color(0xFF56745B),
                  onChanged: (value) {
                    setState(() {
                      stress = value;
                    });
                  },
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Low',
                      style: TextStyle(
                        color: Color(0xFF827C73),
                      ),
                    ),
                    Text(
                      'High',
                      style: TextStyle(
                        color: Color(0xFF827C73),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // -------------------------------
          // SLEEP
          // -------------------------------

          Container(
            padding: const EdgeInsets.all(18),
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
                const Text(
                  'How did you sleep?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${sleep.toStringAsFixed(1)} hours',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF56745B),
                  ),
                ),
                Slider(
                  value: sleep,
                  min: 0,
                  max: 12,
                  divisions: 24,
                  activeColor: const Color(0xFF56745B),
                  onChanged: (value) {
                    setState(() {
                      sleep = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------
          // NOTE
          // -------------------------------

          const Text(
            'Anything you would like to note?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Optional...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------
          // SAVE BUTTON
          // -------------------------------

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: saveCheckIn,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF56745B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Save Check-In',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

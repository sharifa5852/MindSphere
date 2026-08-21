import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

const cream = Color(0xFFFAF8F3);
const paper = Color(0xFFFFFDFA);
const sage = Color(0xFFA8C3A0);
const forest = Color(0xFF56745B);
const ink = Color(0xFF403E38);
const muted = Color(0xFF827C73);
const lavender = Color(0xFFE7E0EF);

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: sage,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text(
                    '🌿',
                    style: TextStyle(fontSize: 42),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // App name
              const Text(
                'MindSphere',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your space to pause,\nreflect & breathe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'A gentle space to understand your emotions, '
                'reflect on your wellbeing, and build healthier '
                'everyday habits.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: muted,
                ),
              ),

              const SizedBox(height: 28),

              // Main feature card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lavender,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: const [
                    Text(
                      '✦  What MindSphere offers',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF685D79),
                      ),
                    ),
                    SizedBox(height: 18),
                    FeatureItem(
                      icon: '😊',
                      title: 'Mood Check-In',
                      description:
                          'Answer a few questions and reflect on how you are feeling.',
                    ),
                    SizedBox(height: 14),
                    FeatureItem(
                      icon: '🧠',
                      title: 'Emotion Insights',
                      description:
                          'An emotion classification model analyzes your responses.',
                    ),
                    SizedBox(height: 14),
                    FeatureItem(
                      icon: '📔',
                      title: 'Personal Journal',
                      description:
                          'Write your thoughts and reflect on your emotional patterns.',
                    ),
                    SizedBox(height: 14),
                    FeatureItem(
                      icon: '✨',
                      title: 'AI Companion',
                      description:
                          'Have a supportive conversation and explore simple wellbeing activities.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: forest,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Signup button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: forest,
                    side: const BorderSide(
                      color: forest,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create an account',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Your wellbeing journey starts with one small step 🌱',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 21),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

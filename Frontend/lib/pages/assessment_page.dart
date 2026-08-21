import 'package:flutter/material.dart';
import 'assessment_result_page.dart';

class AssessmentPage extends StatefulWidget {
  final String title;
  final String type;

  const AssessmentPage({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  int currentQuestion = 0;

  int selectedAnswer = -1;

  final List<int> answers = [];

  final List<String> questions = [
    'How often have you felt overwhelmed by everything you need to do?',
    'How often have you found it difficult to control important things in your life?',
    'How often have you felt tense or under pressure?',
    'How often have you found it difficult to relax?',
    'How often have you felt confident about handling your daily problems?',
    'How often have daily responsibilities felt difficult to manage?',
    'How often have you felt irritated by unexpected events?',
    'How often have you felt that you were coping well with your day?',
    'How often has stress affected your sleep or rest?',
    'How often have you needed a break?'
  ];

  final List<String> options = [
    'Never',
    'Sometimes',
    'Often',
    'Nearly every day',
  ];

  void nextQuestion() {
    if (selectedAnswer == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select an answer.',
          ),
        ),
      );

      return;
    }

    answers.add(selectedAnswer);

    if (currentQuestion == questions.length - 1) {
      double total = 0;

      for (int answer in answers) {
        total += answer;
      }

      double average = total / answers.length;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentResultPage(
            title: widget.title,
            type: widget.type,
            average: average,
          ),
        ),
      );
    } else {
      setState(() {
        currentQuestion++;

        selectedAnswer = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF403E38),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question number

            Text(
              'QUESTION ${currentQuestion + 1} OF ${questions.length}',
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                color: Color(0xFF56745B),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Progress bar

            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
              color: const Color(0xFF56745B),
              backgroundColor: const Color(0xFFE8E4DC),
            ),

            const SizedBox(height: 28),

            // Question

            Text(
              questions[currentQuestion],
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 25),

            // Answers

            ...List.generate(
              options.length,
              (index) {
                return RadioListTile<int>(
                  value: index,
                  groupValue: selectedAnswer,
                  activeColor: const Color(0xFF56745B),
                  title: Text(
                    options[index],
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedAnswer = value!;
                    });
                  },
                );
              },
            ),

            const Spacer(),

            // Next button

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: nextQuestion,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF56745B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  currentQuestion == questions.length - 1
                      ? 'See My Result'
                      : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

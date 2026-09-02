import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'assessment_result_page.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key, required this.title, required this.type});
  final String title;
  final String type;

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  int _currentQuestion = 0;
  int _selectedAnswer = -1;
  bool _isSubmitting = false;
  final List<int> _answers = [];

  List<String> get _questions => widget.type == 'phq9' ? _phq9Questions : _gad7Questions;

  Future<void> _nextQuestion() async {
    if (_selectedAnswer == -1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an answer.')));
      return;
    }
    final answers = [..._answers, _selectedAnswer];
    if (_currentQuestion < _questions.length - 1) {
      setState(() { _answers.add(_selectedAnswer); _currentQuestion++; _selectedAnswer = -1; });
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiService.submitAssessment(type: widget.type, answers: answers);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AssessmentResultPage(
        title: widget.title,
        assessment: Map<String, dynamic>.from(response['assessment'] as Map),
        disclaimer: response['disclaimer'] as String? ?? '',
        supportMessage: response['supportMessage'] as String?,
      )));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiService.readableError(error))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFAF8F3),
    appBar: AppBar(backgroundColor: const Color(0xFFFAF8F3), elevation: 0, title: Text(widget.title, style: const TextStyle(color: Color(0xFF403E38), fontWeight: FontWeight.bold))),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('QUESTION ${_currentQuestion + 1} OF ${_questions.length}', style: const TextStyle(fontSize: 11, letterSpacing: 1.2, color: Color(0xFF56745B), fontWeight: FontWeight.bold)),
      const SizedBox(height: 12), LinearProgressIndicator(value: (_currentQuestion + 1) / _questions.length, color: const Color(0xFF56745B), backgroundColor: const Color(0xFFE8E4DC)),
      const SizedBox(height: 28), Text(_questions[_currentQuestion], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.25)),
      const SizedBox(height: 25),
      ...List.generate(_options.length, (index) => RadioListTile<int>(value: index, groupValue: _selectedAnswer, activeColor: const Color(0xFF56745B), title: Text(_options[index]), onChanged: _isSubmitting ? null : (value) => setState(() => _selectedAnswer = value!))),
      const Spacer(),
      SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: _isSubmitting ? null : _nextQuestion, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF56745B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text(_currentQuestion == _questions.length - 1 ? 'See My Result' : 'Next'))),
    ])),
  );
}

const _options = ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'];

const _phq9Questions = [
  'Little interest or pleasure in doing things?',
  'Feeling down, depressed, or hopeless?',
  'Trouble falling or staying asleep, sleeping too much?',
  'Feeling tired or having little energy?',
  'Poor appetite or overeating?',
  'Feeling bad about yourself — or that you are a failure or have let yourself or your family down?',
  'Trouble concentrating on things, such as reading or watching television?',
  'Moving or speaking so slowly that others could notice, or being unusually fidgety or restless?',
  'Thoughts that you would be better off dead or of hurting yourself in some way?',
];

const _gad7Questions = [
  'Feeling nervous, anxious, or on edge?',
  'Not being able to stop or control worrying?',
  'Worrying too much about different things?',
  'Trouble relaxing?',
  'Being so restless that it is hard to sit still?',
  'Becoming easily annoyed or irritable?',
  'Feeling afraid as if something awful might happen?',
];

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'assessment_result_page.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({
    super.key,
    required this.title,
    required this.type,
  });

  final String title;
  final String type;

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  // ==========================================================
  // MINDSPHERE — SOFT MINT DESIGN SYSTEM
  // ==========================================================

  static const Color primary = Color(0xFFBFE3C0);
  static const Color paleMint = Color(0xFFD9F0DC);
  static const Color freshMint = Color(0xFFC9EACB);
  static const Color calmMint = Color(0xFFB5DFC0);
  static const Color sageMint = Color(0xFFAED8B8);
  static const Color eucalyptus = Color(0xFFA8D5B5);
  static const Color dustyMint = Color(0xFFA5D0B2);
  static const Color celadon = Color(0xFFB7DCC1);
  static const Color morningMint = Color(0xFFC8E7D0);

  static const Color background = Color(0xFFF3FAF5);
  static const Color darkGreen = Color(0xFF2D6A4F);
  static const Color forestText = Color(0xFF1B4332);
  static const Color ink = Color(0xFF13291D);
  static const Color mutedText = Color(0xFF5B7568);
  static const Color softBorder = Color(0xFFE0EEE3);

  int _currentQuestion = 0;
  int _selectedAnswer = -1;
  bool _isSubmitting = false;
  final List<int> _answers = [];

  List<String> get _questions =>
      widget.type == 'phq9' ? _phq9Questions : _gad7Questions;

  double get _progress => (_currentQuestion + 1) / _questions.length;

  String get _assessmentLabel =>
      widget.type == 'phq9' ? 'MOOD & WELL-BEING' : 'ANXIETY & STRESS';

  String get _helperText => widget.type == 'phq9'
      ? 'Answer based on how you have been feeling recently.'
      : 'Answer based on how often these feelings have affected you.';

  Future<void> _nextQuestion() async {
    if (_selectedAnswer == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Choose an option before continuing.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    final answers = [..._answers, _selectedAnswer];

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _answers.add(_selectedAnswer);
        _currentQuestion++;
        _selectedAnswer = -1;
      });
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.submitAssessment(
        type: widget.type,
        answers: answers,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AssessmentResultPage(
            title: widget.title,
            assessment:
                Map<String, dynamic>.from(response['assessment'] as Map),
            disclaimer: response['disclaimer'] as String? ?? '',
            supportMessage: response['supportMessage'] as String?,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.readableError(error)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: darkGreen,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _selectAnswer(int index) {
    if (_isSubmitting) return;
    setState(() => _selectedAnswer = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroCard(),
                    const SizedBox(height: 20),
                    _progressSection(),
                    const SizedBox(height: 22),
                    _questionSection(),
                    const SizedBox(height: 22),
                    _answerOptions(),
                    const SizedBox(height: 8),
                    _privacyNote(),
                    const SizedBox(height: 22),
                    _nextButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 16, 4),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _isSubmitting ? null : () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: forestText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'A private moment to check in with yourself',
                  style: TextStyle(
                    fontSize: 10,
                    color: mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: paleMint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: darkGreen,
                ),
                SizedBox(width: 5),
                Text(
                  'Private',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            paleMint,
            morningMint,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -28,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 38,
            bottom: -36,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.68),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.type == 'phq9'
                      ? Icons.favorite_outline_rounded
                      : Icons.air_rounded,
                  color: darkGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _assessmentLabel,
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Take a breath. There is no perfect answer.',
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: forestText,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _helperText,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: softBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'QUESTION ${_currentQuestion + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w900,
                  color: darkGreen,
                ),
              ),
              const Spacer(),
              Text(
                '${(_progress * 100).round()}% complete',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: _progress,
              color: darkGreen,
              backgroundColor: paleMint,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: List.generate(
              _questions.length,
              (index) => Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(
                    right: index == _questions.length - 1 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: index <= _currentQuestion
                        ? calmMint
                        : const Color(0xFFEAF3EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How have you been feeling?',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: mutedText,
          ),
        ),
        const SizedBox(height: 7),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            _questions[_currentQuestion],
            key: ValueKey(_currentQuestion),
            style: const TextStyle(
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _answerOptions() {
    return Column(
      children: List.generate(
        _options.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _answerCard(
            index: index,
            title: _options[index],
          ),
        ),
      ),
    );
  }

  Widget _answerCard({
    required int index,
    required String title,
  }) {
    final selected = _selectedAnswer == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? paleMint : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? darkGreen : softBorder,
          width: selected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(selected ? 0.08 : 0.035),
            blurRadius: selected ? 16 : 10,
            offset: Offset(0, selected ? 7 : 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _selectAnswer(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? darkGreen : background,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 21,
                          )
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: darkGreen,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600,
                      color: forestText,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? darkGreen : const Color(0xFFC9DCCB),
                      width: 1.6,
                    ),
                    color: selected ? darkGreen : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(
                          Icons.circle,
                          size: 7,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _privacyNote() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EC),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.spa_outlined,
            size: 17,
            color: darkGreen,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Be gentle with yourself. This check-in is here to help you understand your current experience, not judge you.',
              style: TextStyle(
                fontSize: 10,
                height: 1.4,
                color: mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextButton() {
    final isLast = _currentQuestion == _questions.length - 1;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _nextQuestion,
        style: FilledButton.styleFrom(
          backgroundColor: darkGreen,
          disabledBackgroundColor: sageMint,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _isSubmitting
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: ValueKey(isLast),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'See My Result' : 'Continue',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Icon(
                      isLast
                          ? Icons.insights_rounded
                          : Icons.arrow_forward_rounded,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

const _options = [
  'Not at all',
  'Several days',
  'More than half the days',
  'Nearly every day',
];

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

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

  @override
  Widget build(BuildContext context) {
    final result = Map<String, dynamic>.from(
      assessment['result'] as Map? ?? {},
    );

    final level = _readable(result['level']);
    final shouldShowSupport =
        result['considerProfessionalSupport'] == true ||
        result['needsSupportPrompt'] == true;

    final score = assessment['score'] ?? '-';

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                children: [
                  _resultHero(level: level, score: score),
                  const SizedBox(height: 20),
                  _reflectionCard(
                    level: level,
                    supportNeeded: shouldShowSupport,
                  ),
                  const SizedBox(height: 14),
                  _scoreCard(score: score),
                  const SizedBox(height: 14),
                  _supportCard(
                    supportNeeded: shouldShowSupport,
                    message: supportMessage,
                  ),
                  const SizedBox(height: 14),
                  _disclaimerCard(disclaimer),
                  const SizedBox(height: 20),
                  if (shouldShowSupport)
                    _supportButton(context),
                  if (shouldShowSupport) const SizedBox(height: 10),
                  _backButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 16, 4),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Reflection',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'A gentle look at your check-in',
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
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: darkGreen,
                ),
                SizedBox(width: 5),
                Text(
                  'You checked in',
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

  Widget _resultHero({
    required String level,
    required dynamic score,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
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
            color: darkGreen.withOpacity(0.08),
            blurRadius: 26,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -30,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.17),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -35,
            bottom: -48,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.70),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  size: 34,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w900,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Here’s what your check-in shows',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                level,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: forestText,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.64),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Score  $score',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: forestText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reflectionCard({
    required String level,
    required bool supportNeeded,
  }) {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _smallIcon(
                supportNeeded
                    ? Icons.favorite_outline_rounded
                    : Icons.eco_outlined,
                paleMint,
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'A gentle reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: forestText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            supportNeeded
                ? 'Your result suggests that some extra support could be helpful right now.'
                : 'Your result is simply a snapshot of this moment. Be kind to yourself as you reflect on it.',
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.45,
              color: mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard({required dynamic score}) {
    return _whiteCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: freshMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: darkGreen,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your score',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: forestText,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Keep it as a reference, not a label.',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$score',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportCard({
    required bool supportNeeded,
    required String? message,
  }) {
    final cardColor =
        supportNeeded ? const Color(0xFFEAF5EC) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: supportNeeded ? calmMint : softBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _smallIcon(
            supportNeeded
                ? Icons.support_agent_rounded
                : Icons.spa_outlined,
            supportNeeded ? primary : paleMint,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supportNeeded
                      ? 'Support may be helpful'
                      : 'A small next step',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: forestText,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  message ??
                      'Consider taking a short break, trying a breathing exercise, or talking with someone you trust.',
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.45,
                    color: mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimerCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: darkGreen,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9.5,
                height: 1.45,
                color: mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
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
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_rounded,
              size: 19,
            ),
            SizedBox(width: 8),
            Text(
              'Explore professional support',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 7),
            Icon(
              Icons.arrow_forward_rounded,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: darkGreen,
          side: const BorderSide(
            color: calmMint,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: 17,
            ),
            SizedBox(width: 7),
            Text(
              'Back to Assessments',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: softBorder),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _smallIcon(IconData icon, Color backgroundColor) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: darkGreen,
        size: 21,
      ),
    );
  }

  String _readable(dynamic value) {
    return (value as String? ?? 'not available').replaceAll('_', ' ');
  }
}

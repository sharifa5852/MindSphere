
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

// ============================================================
// MINDSHPERE — SOFT MINT COLOR PALETTE
// ============================================================

// Main soft mint
const softMint = Color(0xFFBFE3C0);

// Supporting mint shades
const paleMint = Color(0xFFD9F0DC);
const freshMint = Color(0xFFC9EACB);
const calmMint = Color(0xFFB5DFC0);
const sageMint = Color(0xFFAED8B8);
const eucalyptusMint = Color(0xFFA8D5B5);
const dustyMint = Color(0xFFA5D0B2);
const celadonMint = Color(0xFFB7DCC1);
const morningMint = Color(0xFFC8E7D0);

// Light background
const mintPaper = Color(0xFFF3FAF5);

// Dark green for readable text/buttons
const darkGreen = Color(0xFF2D6A4F);
const forestText = Color(0xFF1B4332);

// Text colors
const inkOnLight = Color(0xFF13291D);
const mutedOnLight = Color(0xFF5B7568);


class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}


class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: paleMint,

      body: Stack(
        children: [

          // =========================================================
          // HERO — SOFT MINT GRADIENT
          // =========================================================

          Container(
            width: double.infinity,
            height: 360,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                colors: [
                  eucalyptusMint,
                  softMint,
                ],
              ),
            ),
          ),


          // =========================================================
          // SOFT GLOW BLOBS
          // =========================================================

          Positioned(
            top: -60,
            right: -50,
            child: _glow(
              180,
              paleMint.withOpacity(0.75),
            ),
          ),

          Positioned(
            top: 60,
            left: -80,
            child: _glow(
              160,
              morningMint.withOpacity(0.75),
            ),
          ),


          // =========================================================
          // MAIN CONTENT
          // =========================================================

          SafeArea(
            bottom: false,

            child: Column(
              children: [

                // =====================================================
                // HERO CONTENT
                // =====================================================

                FadeTransition(
                  opacity: _fade,

                  child: SlideTransition(
                    position: _slide,

                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        28,
                        24,
                        30,
                      ),

                      child: Column(
                        children: [

                          // -------------------------------------------------
                          // LOGO
                          // -------------------------------------------------

                          Container(
                            width: 80,
                            height: 80,

                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,

                                colors: [
                                  sageMint,
                                  eucalyptusMint,
                                ],
                              ),

                              borderRadius: BorderRadius.circular(24),

                              boxShadow: [
                                BoxShadow(
                                  color: eucalyptusMint.withOpacity(0.35),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),

                            child: const Center(
                              child: Text(
                                '🌿',
                                style: TextStyle(
                                  fontSize: 38,
                                ),
                              ),
                            ),
                          ),


                          const SizedBox(height: 18),


                          // -------------------------------------------------
                          // APP NAME
                          // -------------------------------------------------

                          const Text(
                            'MINDSPHERE',

                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 5,
                              color: darkGreen,
                            ),
                          ),


                          const SizedBox(height: 10),


                          // -------------------------------------------------
                          // MAIN TITLE
                          // -------------------------------------------------

                          const Text(
                            'Your space to pause,\nreflect & breathe.',

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 29,
                              height: 1.18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: forestText,
                            ),
                          ),


                          const SizedBox(height: 10),


                          // -------------------------------------------------
                          // DESCRIPTION
                          // -------------------------------------------------

                          Text(
                            'A gentle space to understand your emotions '
                            'and build healthier everyday habits.',

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: forestText.withOpacity(0.78),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                // =========================================================
                // LOWER WHITE / MINT PANEL
                // =========================================================

                Expanded(
                  child: FadeTransition(
                    opacity: _fade,

                    child: Container(
                      width: double.infinity,

                      decoration: const BoxDecoration(
                        color: mintPaper,

                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),

                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          28,
                          24,
                          24,
                        ),

                        child: Column(
                          children: [

                            // -------------------------------------------------
                            // TOP HANDLE
                            // -------------------------------------------------

                            Container(
                              width: 40,
                              height: 4,

                              decoration: BoxDecoration(
                                color: softMint,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),


                            const SizedBox(height: 22),


                            // -------------------------------------------------
                            // SECTION TITLE
                            // -------------------------------------------------

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [

                                Container(
                                  width: 6,
                                  height: 6,

                                  decoration: const BoxDecoration(
                                    color: eucalyptusMint,
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                const Text(
                                  'WHAT MINDSPHERE OFFERS',

                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: darkGreen,
                                  ),
                                ),
                              ],
                            ),


                            const SizedBox(height: 20),


                            // =================================================
                            // FEATURES
                            // =================================================

                            const FeatureItem(
                              icon: '😊',
                              iconBg: paleMint,
                              title: 'Mood Check-In',
                              description:
                                  'Answer a few questions and reflect on how you are feeling.',
                            ),


                            const SizedBox(height: 16),


                            const FeatureItem(
                              icon: '🧠',
                              iconBg: calmMint,
                              title: 'Emotion Insights',
                              description:
                                  'A trained emotion model analyzes your responses.',
                            ),


                            const SizedBox(height: 16),


                            const FeatureItem(
                              icon: '📔',
                              iconBg: morningMint,
                              title: 'Personal Journal',
                              description:
                                  'Write your thoughts and reflect on your emotional patterns.',
                            ),


                            const SizedBox(height: 16),


                            const FeatureItem(
                              icon: '✨',
                              iconBg: celadonMint,
                              title: 'AI Companion',
                              description:
                                  'Have a supportive conversation and explore simple wellbeing activities.',
                            ),


                            const SizedBox(height: 28),


                            // =================================================
                            // LOGIN BUTTON
                            // =================================================

                            SizedBox(
                              width: double.infinity,
                              height: 54,

                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),

                                  boxShadow: [
                                    BoxShadow(
                                      color: eucalyptusMint.withOpacity(0.30),
                                      blurRadius: 22,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),

                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        eucalyptusMint,
                                        sageMint,
                                      ],

                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),

                                    borderRadius: BorderRadius.circular(16),
                                  ),

                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: forestText,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,

                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),

                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LoginPage(),
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
                              ),
                            ),


                            const SizedBox(height: 12),


                            // =================================================
                            // SIGNUP BUTTON
                            // =================================================

                            SizedBox(
                              width: double.infinity,
                              height: 54,

                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(

                                  foregroundColor: darkGreen,

                                  backgroundColor: Colors.white,

                                  side: const BorderSide(
                                    color: softMint,
                                    width: 1.6,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),

                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignupPage(),
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


                            // =================================================
                            // FOOTER
                            // =================================================

                            Text(
                              'Your wellbeing journey starts with one small step 🌱',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                fontSize: 12,
                                color: mutedOnLight,
                                fontStyle: FontStyle.italic,
                              ),
                            ),


                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ============================================================
  // SOFT GLOW
  // ============================================================

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}



// ============================================================
// FEATURE ITEM
// ============================================================

class FeatureItem extends StatelessWidget {
  const FeatureItem({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.description,
  });

  final String icon;
  final Color iconBg;
  final String title;
  final String description;


  @override
  Widget build(BuildContext context) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        // -------------------------------------------------------
        // ICON
        // -------------------------------------------------------

        Container(
          width: 46,
          height: 46,

          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),

          child: Center(
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 21,
              ),
            ),
          ),
        ),


        const SizedBox(width: 14),


        // -------------------------------------------------------
        // TEXT
        // -------------------------------------------------------

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                title,

                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: inkOnLight,
                ),
              ),


              const SizedBox(height: 4),


              Text(
                description,

                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: mutedOnLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

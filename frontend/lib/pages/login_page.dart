import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_shell.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/auth_error_handler.dart';
import 'signup_page.dart';

// ---- Soft Mint / Natural Green palette ----
const mintPrimary = Color(0xFFBFE3C0); // Soft Mint
const mintPale = Color(0xFFD9F0DC); // Pale Mint
const mintFresh = Color(0xFFC9EACB); // Fresh Mint
const mintMorning = Color(0xFFC8E7D0); // Morning Mint
const greenDark = Color(0xFF2D6A4F); // Dark Green (primary action)
const greenDarkLight = Color(0xFF3F8264); // lighter end for gradients
const forestText = Color(0xFF1B4332); // Forest Text
const inkOnLight = Color(0xFF13291D); // Main text
const mutedOnLight = Color(0xFF5B7568); // Secondary text
const mintPaper = Color(0xFFF3FAF5); // Background

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isSubmitting = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: forestText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter your email and password.');
      return;
    }

    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    try {
      final userCredential = await _authService.login(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        showMessage('Login failed. Please try again.');
        return;
      }

      debugPrint('Firebase login successful');
      debugPrint('Firebase UID: ${user.uid}');

      if (!mounted) return;

      await ApiService.syncUser(
        name: user.displayName ?? 'MindSphere User',
      );

      debugPrint('User synchronized with backend.');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showMessage(getAuthErrorMessage(e.code));
      debugPrint('Firebase Auth Error Code: ${e.code}');
      debugPrint('Firebase Auth Error Message: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      debugPrint('Login/backend error: $e');
      showMessage(ApiService.readableError(e));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: mutedOnLight, fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(color: mutedOnLight),
      prefixIcon: Icon(icon, color: greenDark, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: mintFresh, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: mintFresh, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: greenDark, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 375).clamp(0.85, 1.15);
    final isCompactHeight = size.height < 700;

    return Scaffold(
      backgroundColor: mintPaper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, isCompactHeight ? 12 : 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // -----------------------------------------------
                  // LOGO + BRAND — soft mint badge with gradient ring
                  // -----------------------------------------------
                  Center(
                    child: Container(
                      width: 72 * scale,
                      height: 72 * scale,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [mintPrimary, mintFresh],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: mintPrimary.withOpacity(0.55),
                            blurRadius: 26,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text('🌿', style: TextStyle(fontSize: 34 * scale)),
                      ),
                    ),
                  ),

                  SizedBox(height: isCompactHeight ? 16 : 22),

                  Center(
                    child: Text(
                      'MINDSPHERE',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: greenDark,
                      ),
                    ),
                  ),

                  SizedBox(height: isCompactHeight ? 10 : 14),

                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (isCompactHeight ? 27 : 32) * scale,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: forestText,
                    ),
                  ),

                  SizedBox(height: isCompactHeight ? 6 : 10),

                  Text(
                    'A gentler way to understand your wellbeing,\none small check-in at a time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5 * scale,
                      height: 1.5,
                      color: mutedOnLight,
                    ),
                  ),

                  SizedBox(height: isCompactHeight ? 26 : 36),

                  // -----------------------------------------------
                  // FORM CARD
                  // -----------------------------------------------
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: forestText.withOpacity(0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: inkOnLight),
                          decoration: _fieldDecoration(
                            label: 'Email',
                            hint: 'you@example.com',
                            icon: Icons.mail_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: passwordController,
                          obscureText: hidePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => login(),
                          style: const TextStyle(color: inkOnLight),
                          decoration: _fieldDecoration(
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => hidePassword = !hidePassword);
                              },
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: mutedOnLight,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: greenDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5 * scale,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isCompactHeight ? 12 : 18),

                        // LOGIN BUTTON — gradient, dark green
                        SizedBox(
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [greenDark, greenDarkLight],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: greenDark.withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: isSubmitting ? null : login,
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Log in',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15.5 * scale,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isCompactHeight ? 18 : 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: mutedOnLight, fontSize: 13 * scale),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          );
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: greenDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13 * scale,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isCompactHeight ? 10 : 16),

                  Center(
                    child: Text(
                      'Your wellbeing journey starts with one small step 🌱',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5 * scale,
                        color: mutedOnLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
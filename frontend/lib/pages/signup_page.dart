import 'email_verification_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../app_shell.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/auth_error_handler.dart';

// ---- Soft Mint / Natural Green palette (matches login_page.dart) ----
const _mintPrimary = Color(0xFFBFE3C0); // Soft Mint
const _mintFresh = Color(0xFFC9EACB); // Fresh Mint
const _mintMorning = Color(0xFFC8E7D0); // Morning Mint
const _greenDark = Color(0xFF2D6A4F); // Dark Green (primary action)
const _greenDarkLight = Color(0xFF3F8264); // lighter end for gradients
const _forestText = Color(0xFF1B4332); // Forest Text
const _inkOnLight = Color(0xFF13291D); // Main text
const _mutedOnLight = Color(0xFF5B7568); // Secondary text
const _mintPaper = Color(0xFFF3FAF5); // Background

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthService _authService = AuthService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool agreeToPrivacy = false;
  bool isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    if (!email.contains('@')) {
      showMessage('Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password should contain at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match.');
      return;
    }

    if (!agreeToPrivacy) {
      showMessage('Please agree to the privacy terms.');
      return;
    }

    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    showMessage('Creating your account...');

    try {
      final userCredential = await _authService.signUp(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        showMessage('Account creation failed.');
        return;
      }

      debugPrint('Firebase signup successful');
      debugPrint('Firebase UID: ${user.uid}');
      debugPrint('Firebase email: ${user.email}');

      await user.updateDisplayName(name);
     
         // Send the verification email now, right after the account is created.
      await user.sendEmailVerification();

      if (!mounted) return;
      showMessage('Saving your profile...');

      await ApiService.syncUser(name: name);

      debugPrint('User synchronized with backend.');

      if (!mounted) return;

      showMessage('Account created — check your email to verify ✓');

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerificationPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showMessage(getAuthErrorMessage(e.code));
      debugPrint('Firebase Auth Error Code: ${e.code}');
      debugPrint('Firebase Auth Error Message: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      debugPrint('Signup/backend error: $e');
      showMessage(ApiService.readableError(e));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _forestText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
      labelStyle: const TextStyle(color: _mutedOnLight, fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(color: _mutedOnLight),
      prefixIcon: Icon(icon, color: _greenDark, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _mintFresh, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _mintFresh, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _greenDark, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 375).clamp(0.85, 1.15);
    final isCompactHeight = size.height < 700;

    return Scaffold(
      backgroundColor: _mintPaper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, isCompactHeight ? 6 : 12, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: _forestText,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isCompactHeight ? 6 : 10),

                  // Logo
                  Center(
                    child: Container(
                      width: 66 * scale,
                      height: 66 * scale,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_mintPrimary, _mintFresh],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _mintPrimary.withOpacity(0.5),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text('🌿', style: TextStyle(fontSize: 30 * scale)),
                      ),
                    ),
                  ),

                  SizedBox(height: isCompactHeight ? 14 : 20),

                  Center(
                    child: Text(
                      'Create your space',
                      style: TextStyle(
                        fontSize: (isCompactHeight ? 24 : 28) * scale,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: _forestText,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Start your MindSphere journey\nwith a few simple details.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5 * scale,
                        height: 1.45,
                        color: _mutedOnLight,
                      ),
                    ),
                  ),

                  SizedBox(height: isCompactHeight ? 22 : 30),

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
                          color: _forestText.withOpacity(0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: _inkOnLight),
                          decoration: _fieldDecoration(
                            label: 'Full name',
                            hint: 'Enter your name',
                            icon: Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: _inkOnLight),
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
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: _inkOnLight),
                          decoration: _fieldDecoration(
                            label: 'Password',
                            hint: 'At least 6 characters',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => hidePassword = !hidePassword);
                              },
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _mutedOnLight,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: hideConfirmPassword,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(color: _inkOnLight),
                          decoration: _fieldDecoration(
                            label: 'Confirm password',
                            hint: 'Re-enter your password',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => hideConfirmPassword = !hideConfirmPassword);
                              },
                              icon: Icon(
                                hideConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _mutedOnLight,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isCompactHeight ? 14 : 18),

                        // Privacy agreement — pale mint chip
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _mintMorning.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _mintFresh, width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: agreeToPrivacy,
                                activeColor: _greenDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() => agreeToPrivacy = value ?? false);
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 11),
                                  child: Text(
                                    'I understand that MindSphere provides '
                                    'wellbeing support and is not a medical diagnosis tool.',
                                    style: TextStyle(
                                      fontSize: 12 * scale,
                                      height: 1.4,
                                      color: _forestText,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isCompactHeight ? 16 : 22),

                        // Create account button — gradient, dark green
                        SizedBox(
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [_greenDark, _greenDarkLight],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _greenDark.withOpacity(0.35),
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
                              onPressed: isSubmitting ? null : createAccount,
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
                                      'Create account',
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

                  SizedBox(height: isCompactHeight ? 18 : 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: _mutedOnLight, fontSize: 13 * scale),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            color: _greenDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13 * scale,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isCompactHeight ? 8 : 12),

                  Center(
                    child: Text(
                      'Your wellbeing journey starts with one small step 🌱',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11 * scale,
                        color: _mutedOnLight,
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
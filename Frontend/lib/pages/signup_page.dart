import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../app_shell.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/auth_error_handler.dart';

const cream = Color(0xFFFAF8F3);
const paper = Color(0xFFFFFDFA);
const sage = Color(0xFFA8C3A0);
const forest = Color(0xFF56745B);
const ink = Color(0xFF403E38);
const muted = Color(0xFF827C73);
const lavender = Color(0xFFE7E0EF);

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

    // -----------------------------
    // 1. Basic validation
    // -----------------------------

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
      // -----------------------------
      // 2. Create Firebase account
      // -----------------------------

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

      // -----------------------------
      // 3. Save the user's name on the Firebase profile
      // -----------------------------

      await user.updateDisplayName(name);

      // -----------------------------
      // 4. Synchronize with Express + MongoDB backend
      // -----------------------------

      if (!mounted) return;
      showMessage('Saving your profile...');

      await ApiService.syncUser(name: name);

      debugPrint('User synchronized with backend.');

      if (!mounted) return;

      showMessage('Account created successfully ✓');

      // -----------------------------
      // 5. Go to the main app
      // -----------------------------

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AppShell(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      showMessage(getAuthErrorMessage(e.code));

      debugPrint('Firebase Auth Error Code: ${e.code}');
      debugPrint('Firebase Auth Error Message: ${e.message}');
    } catch (e) {
      if (!mounted) return;

      debugPrint('Signup/backend error: $e');

      // Firebase account may already exist even though the backend
      // sync failed — the next login attempt will retry the sync.
      showMessage(
        'Account created, but your profile could not be saved. '
        'Please try logging in again.',
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          children: [
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                color: ink,
              ),
            ),

            const SizedBox(height: 5),

            // Logo
            Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: sage,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Center(
                  child: Text(
                    '🌿',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Center(
              child: Text(
                'Create your space',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                'Start your MindSphere journey\nwith a few simple details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: muted,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Name
            const Text(
              'Full name',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),

            const SizedBox(height: 7),

            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: paper,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE9E3D9),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Email
            const Text(
              'Email',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),

            const SizedBox(height: 7),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: paper,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE9E3D9),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Password
            const Text(
              'Password',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),

            const SizedBox(height: 7),

            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'At least 6 characters',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                filled: true,
                fillColor: paper,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE9E3D9),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Confirm password
            const Text(
              'Confirm password',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),

            const SizedBox(height: 7),

            TextField(
              controller: confirmPasswordController,
              obscureText: hideConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      hideConfirmPassword = !hideConfirmPassword;
                    });
                  },
                  icon: Icon(
                    hideConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                filled: true,
                fillColor: paper,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE9E3D9),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Privacy agreement
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: lavender.withOpacity(0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agreeToPrivacy,
                    activeColor: forest,
                    onChanged: (value) {
                      setState(() {
                        agreeToPrivacy = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 11),
                      child: Text(
                        'I understand that MindSphere provides '
                        'wellbeing support and is not a medical diagnosis tool.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Create account button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isSubmitting ? null : createAccount,
                style: FilledButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create account',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 18),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: forest,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Your wellbeing journey starts with one small step 🌱',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
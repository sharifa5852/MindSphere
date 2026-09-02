import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_shell.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/auth_error_handler.dart';
import 'signup_page.dart';

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
      SnackBar(content: Text(message)),
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
      // -----------------------------
      // 1. Sign in with Firebase
      // -----------------------------

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

      // -----------------------------
      // 2. Synchronize with Express + MongoDB backend
      // -----------------------------

      if (!mounted) return;

      await ApiService.syncUser(
        name: user.displayName ?? 'MindSphere User',
      );

      debugPrint('User synchronized with backend.');

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

      debugPrint('Login/backend error: $e');

      showMessage(ApiService.readableError(e));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ListView(
            children: [
              const SizedBox(height: 30),

              // Logo
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFA8C3A0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    '🌿',
                    style: TextStyle(fontSize: 27),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'MindSphere',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Your space to pause,\nreflect & breathe.',
                style: TextStyle(
                  fontSize: 36,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF403E38),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'A gentler way to understand your wellbeing, '
                'one small check-in at a time.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF827C73),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              // Email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Password
              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => login(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '••••••••',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
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
                ),
              ),

              const SizedBox(height: 18),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF56745B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isSubmitting ? null : login,
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
                          'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: Color(0xFF56745B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

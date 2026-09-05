import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_shell.dart';
import 'email_verification_page.dart';
import 'welcome_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFAF8F3),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (user.emailVerified) {
            return const AppShell();
          }
          return const EmailVerificationPage();
        }

        return const WelcomePage();
      },
    );
  }
}

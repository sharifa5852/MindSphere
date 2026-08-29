import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_shell.dart';
import 'welcome_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking whether a session exists — show a brief loader
        // instead of flashing the WelcomePage first.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFAF8F3),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // A signed-in Firebase user exists (survives app restarts).
        if (snapshot.hasData) {
          return const AppShell();
        }

        // No signed-in user.
        return const WelcomePage();
      },
    );
  }
}
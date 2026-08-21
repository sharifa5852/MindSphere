import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MindSphereApp());
}

class MindSphereApp extends StatelessWidget {
  const MindSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindSphere',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF8F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF56745B),
        ),
        fontFamily: 'Roboto',
      ),
      home: const WelcomePage(),
    );
  }
}

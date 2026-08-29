import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/auth_gate.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    print('Firebase initialized successfully');

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
     home: const AuthGate(),
    );
  }
}

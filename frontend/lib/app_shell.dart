import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/mood_checkin_page.dart';
import 'pages/ai_companion_page.dart';
import 'pages/insights_page.dart';
import 'pages/profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(),
      MoodCheckInPage(),
      AiCompanionPage(),
      InsightsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: changePage,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDDEBD9),
        destinations: const [
          // HOME
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          // MOOD
          NavigationDestination(
            icon: Icon(Icons.sentiment_satisfied_outlined),
            selectedIcon: Icon(Icons.sentiment_satisfied),
            label: 'Mood',
          ),

          // AI
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),

          // INSIGHTS
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),

          // PROFILE
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

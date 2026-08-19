import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF403E38),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // PROFILE PHOTO
          const CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFF1DCDD),
            child: Text(
              '👩',
              style: TextStyle(
                fontSize: 38,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // NAME
          const Center(
            child: Text(
              'Sharifatun Nur',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF403E38),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // UNIVERSITY
          const Center(
            child: Text(
              'CUET · CSE',
              style: TextStyle(
                color: Color(0xFF827C73),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // EDIT PROFILE
          Center(
            child: OutlinedButton(
              onPressed: () {},
              child: const Text(
                'Edit profile',
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'MY PREFERENCES',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: Color(0xFF56745B),
            ),
          ),

          const SizedBox(height: 10),

          // PREFERENCES
          ProfileOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
          ),

          ProfileOption(
            icon: Icons.dark_mode_outlined,
            title: 'Appearance',
          ),

          ProfileOption(
            icon: Icons.access_time,
            title: 'Check-in time',
          ),

          const SizedBox(height: 25),

          const Text(
            'PRIVACY',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: Color(0xFF56745B),
            ),
          ),

          const SizedBox(height: 10),

          ProfileOption(
            icon: Icons.lock_outline,
            title: 'Privacy settings',
          ),

          ProfileOption(
            icon: Icons.description_outlined,
            title: 'Data & journal',
          ),

          const SizedBox(height: 30),

          // LOGOUT
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Log out',
                style: TextStyle(
                  color: Color(0xFF56745B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------
// PROFILE OPTION
// ------------------------------------------------------

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF56745B),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF403E38),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {
          // Functionality will be added later.
        },
      ),
    );
  }
}

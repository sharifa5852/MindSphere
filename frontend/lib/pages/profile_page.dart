// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import 'professional_support_page.dart';
// import 'wellness_reports_page.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAF8F3),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFAF8F3),
//         elevation: 0,
//         title: const Text(
//           'Profile',
//           style: TextStyle(
//             color: Color(0xFF403E38),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           // PROFILE PHOTO
//           const CircleAvatar(
//             radius: 42,
//             backgroundColor: Color(0xFFF1DCDD),
//             child: Text(
//               '👩',
//               style: TextStyle(
//                 fontSize: 38,
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // NAME
//           const Center(
//             child: Text(
//               'Sharifatun Nur',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF403E38),
//               ),
//             ),
//           ),

//           const SizedBox(height: 4),

//           // UNIVERSITY
//           const Center(
//             child: Text(
//               'CUET · CSE',
//               style: TextStyle(
//                 color: Color(0xFF827C73),
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // EDIT PROFILE
//           Center(
//             child: OutlinedButton(
//               onPressed: () {},
//               child: const Text(
//                 'Edit profile',
//               ),
//             ),
//           ),

//           const SizedBox(height: 25),

//           const Text(
//             'MY PREFERENCES',
//             style: TextStyle(
//               fontSize: 12,
//               letterSpacing: 1,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF56745B),
//             ),
//           ),

//           const SizedBox(height: 10),

//           // PREFERENCES
//           const ProfileOption(
//             icon: Icons.notifications_outlined,
//             title: 'Notifications',
//           ),

//           const ProfileOption(
//             icon: Icons.dark_mode_outlined,
//             title: 'Appearance',
//           ),

//           const ProfileOption(
//             icon: Icons.access_time,
//             title: 'Check-in time',
//           ),

//           const SizedBox(height: 25),

//           const Text(
//             'PRIVACY',
//             style: TextStyle(
//               fontSize: 12,
//               letterSpacing: 1,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF56745B),
//             ),
//           ),

//           const SizedBox(height: 10),

//           const ProfileOption(
//             icon: Icons.lock_outline,
//             title: 'Privacy settings',
//           ),

//           const ProfileOption(
//             icon: Icons.description_outlined,
//             title: 'Data & journal',
//           ),

//           const SizedBox(height: 25),

//           const Text(
//             'SUPPORT',
//             style: TextStyle(
//               fontSize: 12,
//               letterSpacing: 1,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF56745B),
//             ),
//           ),

//           const SizedBox(height: 10),

//           ProfileOption(
//             icon: Icons.support_agent_outlined,
//             title: 'Professional support',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const ProfessionalSupportPage(),
//                 ),
//               );
//             },
//           ),

//           ProfileOption(
//             icon: Icons.summarize_outlined,
//             title: 'Weekly & monthly reports',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const WellnessReportsPage(),
//                 ),
//               );
//             },
//           ),

//           const SizedBox(height: 30),

//           // LOGOUT
//           Center(
//             child: TextButton(
//               onPressed: () async {
//   await AuthService().logout();
//   if (!context.mounted) return;
//   Navigator.of(context).popUntil((route) => route.isFirst);
// },
//               child: const Text(
//                 'Log out',
//                 style: TextStyle(
//                   color: Color(0xFF56745B),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ------------------------------------------------------
// // PROFILE OPTION
// // ------------------------------------------------------

// class ProfileOption extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback? onTap;

//   const ProfileOption({
//     super.key,
//     required this.icon,
//     required this.title,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 2),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//       ),
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: const Color(0xFF56745B),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(
//             color: Color(0xFF403E38),
//           ),
//         ),
//         trailing: const Icon(
//           Icons.chevron_right,
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'professional_support_page.dart';
import 'wellness_reports_page.dart';

const _forest = Color(0xFF56745B);
const _ink = Color(0xFF403E38);
const _muted = Color(0xFF827C73);
const _cream = Color(0xFFFAF8F3);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  String? loadError;

  String name = 'MindSphere User';
  String email = '';
  bool notificationsEnabled = true;
  String checkInTime = '20:00'; // HH:mm, 24-hour
  String theme = 'system'; // system | light | dark

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    // Sensible fallback from Firebase in case the backend call fails.
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      name = firebaseUser.displayName ?? name;
      email = firebaseUser.email ?? email;
    }

    try {
      final response = await ApiService.getCurrentUser();
      final user = Map<String, dynamic>.from(response['user'] as Map);
      final preferences = Map<String, dynamic>.from(
        user['preferences'] as Map? ?? {},
      );

      setState(() {
        name = (user['name'] as String?)?.trim().isNotEmpty == true
            ? user['name'] as String
            : name;
        email = (user['email'] as String?) ?? email;
        notificationsEnabled =
            preferences['notificationsEnabled'] as bool? ??
                notificationsEnabled;
        checkInTime = (preferences['checkInTime'] as String?) ?? checkInTime;
        theme = (preferences['theme'] as String?) ?? theme;
        isLoading = false;
      });
    } catch (e) {
      // Don't block the whole page on a network hiccup — show what we
      // have from Firebase and let the user retry.
      setState(() {
        isLoading = false;
        loadError = ApiService.readableError(e);
      });
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _themeLabel(String value) {
    switch (value) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System';
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: name);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Full name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty || result == name) return;

    final previous = name;
    setState(() => name = result);

    try {
      await ApiService.updateProfile(name: result);
      // Keep Firebase's own profile copy in sync too.
      await FirebaseAuth.instance.currentUser?.updateDisplayName(result);
      _showSnack('Name updated.');
    } catch (e) {
      if (!mounted) return;
      setState(() => name = previous);
      _showSnack(ApiService.readableError(e));
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final previous = notificationsEnabled;
    setState(() => notificationsEnabled = value);

    try {
      await ApiService.updateProfile(notificationsEnabled: value);
    } catch (e) {
      if (!mounted) return;
      setState(() => notificationsEnabled = previous);
      _showSnack(ApiService.readableError(e));
    }
  }

  Future<void> _editTheme() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Appearance'),
        children: ['system', 'light', 'dark'].map((value) {
          return RadioListTile<String>(
            value: value,
            groupValue: theme,
            activeColor: _forest,
            title: Text(_themeLabel(value)),
            onChanged: (v) => Navigator.pop(context, v),
          );
        }).toList(),
      ),
    );

    if (result == null || result == theme) return;

    final previous = theme;
    setState(() => theme = result);

    try {
      await ApiService.updateProfile(theme: result);
    } catch (e) {
      if (!mounted) return;
      setState(() => theme = previous);
      _showSnack(ApiService.readableError(e));
    }
  }

  Future<void> _editCheckInTime() async {
    final parts = checkInTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 20,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    if (formatted == checkInTime) return;

    final previous = checkInTime;
    setState(() => checkInTime = formatted);

    try {
      await ApiService.updateProfile(checkInTime: formatted);
    } catch (e) {
      if (!mounted) return;
      setState(() => checkInTime = previous);
      _showSnack(ApiService.readableError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: _ink, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (loadError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6EDCC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off, color: _muted, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing local info — could not reach the server.',
                              style: const TextStyle(color: _muted, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadProfile,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // PROFILE PHOTO
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0xFFF1DCDD),
                    child: Text('👩', style: TextStyle(fontSize: 38)),
                  ),

                  const SizedBox(height: 12),

                  // NAME
                  Center(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // EMAIL
                  Center(
                    child: Text(
                      email,
                      style: const TextStyle(color: _muted),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // EDIT PROFILE
                  Center(
                    child: OutlinedButton(
                      onPressed: _editName,
                      child: const Text('Edit profile'),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'MY PREFERENCES',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: _forest,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // PREFERENCES
                  ProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    trailing: Switch(
                      value: notificationsEnabled,
                      activeColor: _forest,
                      onChanged: _toggleNotifications,
                    ),
                  ),

                  ProfileOption(
                    icon: Icons.dark_mode_outlined,
                    title: 'Appearance',
                    trailingText: _themeLabel(theme),
                    onTap: _editTheme,
                  ),

                  ProfileOption(
                    icon: Icons.access_time,
                    title: 'Check-in time',
                    trailingText: TimeOfDay(
                      hour: int.tryParse(checkInTime.split(':')[0]) ?? 20,
                      minute: int.tryParse(checkInTime.split(':')[1]) ?? 0,
                    ).format(context),
                    onTap: _editCheckInTime,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'PRIVACY',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: _forest,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const ProfileOption(
                    icon: Icons.lock_outline,
                    title: 'Privacy settings',
                  ),

                  const ProfileOption(
                    icon: Icons.description_outlined,
                    title: 'Data & journal',
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'SUPPORT',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: _forest,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ProfileOption(
                    icon: Icons.support_agent_outlined,
                    title: 'Professional support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfessionalSupportPage(),
                        ),
                      );
                    },
                  ),

                  ProfileOption(
                    icon: Icons.summarize_outlined,
                    title: 'Weekly & monthly reports',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WellnessReportsPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // LOGOUT
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await AuthService().logout();
                        if (!context.mounted) return;
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text(
                        'Log out',
                        style: TextStyle(
                          color: _forest,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailing,
    this.onTap,
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
          color: _forest,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: _ink,
          ),
        ),
        trailing: trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      trailingText!,
                      style: const TextStyle(color: _muted),
                    ),
                  ),
                const Icon(Icons.chevron_right),
              ],
            ),
        onTap: onTap,
      ),
    );
  }
}
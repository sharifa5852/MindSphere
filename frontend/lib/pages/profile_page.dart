
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'professional_support_page.dart';
import 'wellness_reports_page.dart';
import 'journal_page.dart';
// ============================================================
// MINDSPHERE — SOFT MINT DESIGN SYSTEM
// ============================================================

const _primary = Color(0xFFBFE3C0);
const _paleMint = Color(0xFFD9F0DC);
const _freshMint = Color(0xFFC9EACB);
const _calmMint = Color(0xFFB5DFC0);
const _sageMint = Color(0xFFAED8B8);
const _eucalyptus = Color(0xFFA8D5B5);
const _celadon = Color(0xFFB7DCC1);
const _morningMint = Color(0xFFC8E7D0);

const _background = Color(0xFFF3FAF5);
const _darkGreen = Color(0xFF2D6A4F);
const _forestText = Color(0xFF1B4332);
const _ink = Color(0xFF13291D);
const _mutedText = Color(0xFF5B7568);

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
  String checkInTime = '20:00';
  String theme = 'system';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // PROFILE DATA
  // ============================================================

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      name = firebaseUser.displayName ?? name;
      email = firebaseUser.email ?? email;
    }

    try {
      final response = await ApiService.getCurrentUser();

      final user = Map<String, dynamic>.from(
        response['user'] as Map,
      );

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

        checkInTime =
            (preferences['checkInTime'] as String?) ?? checkInTime;

        theme =
            (preferences['theme'] as String?) ?? theme;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        loadError = ApiService.readableError(e);
      });
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _darkGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
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

  // ============================================================
  // EDIT NAME
  // ============================================================

  Future<void> _editName() async {
    final controller = TextEditingController(text: name);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Edit your name',
          style: TextStyle(
            color: _forestText,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Full name',
            filled: true,
            fillColor: _background,
            prefixIcon: const Icon(
              Icons.person_outline_rounded,
              color: _darkGreen,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _mutedText),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _darkGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pop(
                context,
                controller.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty || result == name) {
      return;
    }

    final previous = name;

    setState(() => name = result);

    try {
      await ApiService.updateProfile(name: result);

      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(result);

      _showSnack('Name updated.');
    } catch (e) {
      if (!mounted) return;

      setState(() => name = previous);

      _showSnack(
        ApiService.readableError(e),
      );
    }
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> _toggleNotifications(bool value) async {
    final previous = notificationsEnabled;

    setState(() {
      notificationsEnabled = value;
    });

    try {
      await ApiService.updateProfile(
        notificationsEnabled: value,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        notificationsEnabled = previous;
      });

      _showSnack(
        ApiService.readableError(e),
      );
    }
  }

  // ============================================================
  // THEME
  // ============================================================

  Future<void> _editTheme() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Appearance',
          style: TextStyle(
            color: _forestText,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: ['system', 'light', 'dark'].map((value) {
          return RadioListTile<String>(
            value: value,
            groupValue: theme,
            activeColor: _darkGreen,
            title: Text(
              _themeLabel(value),
              style: const TextStyle(
                color: _forestText,
                fontWeight: FontWeight.w600,
              ),
            ),
            onChanged: (v) {
              Navigator.pop(context, v);
            },
          );
        }).toList(),
      ),
    );

    if (result == null || result == theme) {
      return;
    }

    final previous = theme;

    setState(() {
      theme = result;
    });

    try {
      await ApiService.updateProfile(
        theme: result,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        theme = previous;
      });

      _showSnack(
        ApiService.readableError(e),
      );
    }
  }

  // ============================================================
  // CHECK-IN TIME
  // ============================================================

  Future<void> _editCheckInTime() async {
    final parts = checkInTime.split(':');

    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 20,
      minute: int.tryParse(
            parts.length > 1 ? parts[1] : '0',
          ) ??
          0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked == null) return;

    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';

    if (formatted == checkInTime) {
      return;
    }

    final previous = checkInTime;

    setState(() {
      checkInTime = formatted;
    });

    try {
      await ApiService.updateProfile(
        checkInTime: formatted,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        checkInTime = previous;
      });

      _showSnack(
        ApiService.readableError(e),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: _darkGreen,
                ),
              )
            : RefreshIndicator(
                color: _darkGreen,
                backgroundColor: Colors.white,
                onRefresh: _loadProfile,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    36,
                  ),
                  children: [
                    _topBar(),

                    const SizedBox(height: 18),

                    if (loadError != null) ...[
                      _offlineBanner(),
                      const SizedBox(height: 16),
                    ],

                    _profileHero(),

                    const SizedBox(height: 26),

                    _sectionHeader(
                      eyebrow: 'PERSONALIZE',
                      title: 'Your preferences',
                      subtitle:
                          'Make MindSphere feel a little more like you.',
                    ),

                    const SizedBox(height: 12),

                    _preferenceCard(),

                    const SizedBox(height: 26),

                    _sectionHeader(
                      eyebrow: 'YOUR SPACE',
                      title: 'Privacy & data',
                      subtitle:
                          'Your reflections should always feel personal.',
                    ),

                    const SizedBox(height: 12),

                    _privacyCard(),

                    const SizedBox(height: 26),

                    _sectionHeader(
                      eyebrow: 'CARE & SUPPORT',
                      title: 'Support',
                      subtitle:
                          'Helpful resources whenever you need them.',
                    ),

                    const SizedBox(height: 12),

                    _supportCard(),

                    const SizedBox(height: 26),

                    _wellnessNote(),

                    const SizedBox(height: 22),

                    _logoutButton(),

                    const SizedBox(height: 8),

                    const Center(
                      child: Text(
                        'MindSphere • a calmer space for you',
                        style: TextStyle(
                          fontSize: 10,
                          color: _mutedText,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _topBar() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: _forestText,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: _ink,
              letterSpacing: -0.4,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: _paleMint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 13,
                color: _darkGreen,
              ),
              SizedBox(width: 5),
              Text(
                'Personal',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _darkGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OFFLINE BANNER
  // ============================================================

  Widget _offlineBanner() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _freshMint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _sageMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 18,
              color: _darkGreen,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Showing saved information — the server could not be reached.',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: _forestText,
              ),
            ),
          ),

          TextButton(
            onPressed: _loadProfile,
            style: TextButton.styleFrom(
              foregroundColor: _darkGreen,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE HERO
  // ============================================================

  Widget _profileHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primary,
            _paleMint,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -32,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.17),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 45,
            bottom: -46,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.65),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '🌿',
                        style: TextStyle(
                          fontSize: 34,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'YOUR MINDSPACE',
                            style: TextStyle(
                              fontSize: 8.5,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                              color: _darkGreen,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 21,
                            height: 1.08,
                            fontWeight: FontWeight.w800,
                            color: _forestText,
                            letterSpacing: -0.4,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          email.isEmpty
                              ? 'Your personal wellness space'
                              : email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 19),

              Row(
                children: [
                  Expanded(
                    child: _profileMiniCard(
                      icon: Icons.notifications_none_rounded,
                      label: 'Reminders',
                      value: notificationsEnabled
                          ? 'On'
                          : 'Off',
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: _profileMiniCard(
                      icon: Icons.schedule_rounded,
                      label: 'Check-in',
                      value: _formattedCheckInTime(),
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: _profileMiniCard(
                      icon: Icons.brightness_6_outlined,
                      label: 'Theme',
                      value: _themeLabel(theme),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _editName,
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'Edit profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE MINI CARD
  // ============================================================

  Widget _profileMiniCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.57),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.52),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 17,
            color: _darkGreen,
          ),

          const SizedBox(height: 5),

          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              color: _mutedText,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: _forestText,
            ),
          ),
        ],
      ),
    );
  }

  String _formattedCheckInTime() {
    final parts = checkInTime.split(':');

    final time = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 20,
      minute:
          int.tryParse(parts.length > 1 ? parts[1] : '0') ??
              0,
    );

    return time.format(context);
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
            color: _darkGreen,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: _mutedText,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PREFERENCES
  // ============================================================

  Widget _preferenceCard() {
    return _groupCard(
      children: [
        _settingTile(
          icon: Icons.notifications_none_rounded,
          iconBackground: _paleMint,
          title: 'Notifications',
          subtitle: 'Gentle reminders for your check-ins',
          trailing: Switch(
            value: notificationsEnabled,
            activeColor: _darkGreen,
            activeTrackColor: _calmMint,
            inactiveThumbColor: _mutedText,
            inactiveTrackColor: _paleMint,
            onChanged: _toggleNotifications,
          ),
        ),

        _divider(),

        _settingTile(
          icon: Icons.palette_outlined,
          iconBackground: _freshMint,
          title: 'Appearance',
          subtitle: 'Choose how MindSphere looks',
          trailing: _valuePill(
            _themeLabel(theme),
          ),
          onTap: _editTheme,
        ),

        _divider(),

        _settingTile(
          icon: Icons.schedule_rounded,
          iconBackground: _morningMint,
          title: 'Daily check-in',
          subtitle: 'Your preferred reflection time',
          trailing: _valuePill(
            _formattedCheckInTime(),
          ),
          onTap: _editCheckInTime,
        ),
      ],
    );
  }

  // ============================================================
  // PRIVACY
  // ============================================================

Widget _privacyCard() {
  return _groupCard(
    children: [
      _settingTile(
        icon: Icons.lock_outline_rounded,
        iconBackground: _calmMint,
        title: 'Privacy settings',
        subtitle: 'Manage how your information is handled',
        onTap: () {},
      ),

      _divider(),

      _settingTile(
        icon: Icons.menu_book_outlined,
        iconBackground: _celadon,
        title: 'Data & journal',
        subtitle: 'Your reflections and personal entries',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const JournalPage(),
            ),
          );
        },
      ),
    ],
  );
}

  // ============================================================
  // SUPPORT
  // ============================================================

  Widget _supportCard() {
    return _groupCard(
      children: [
        _settingTile(
          icon: Icons.support_agent_rounded,
          iconBackground: _sageMint,
          title: 'Professional support',
          subtitle: 'Explore trusted mental wellness resources',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ProfessionalSupportPage(),
              ),
            );
          },
        ),

        _divider(),

        _settingTile(
          icon: Icons.insights_rounded,
          iconBackground: _eucalyptus,
          title: 'Weekly & monthly reports',
          subtitle: 'See patterns across your wellness journey',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const WellnessReportsPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // GROUP CARD
  // ============================================================

  Widget _groupCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _paleMint,
        ),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // ============================================================
  // SETTING TILE
  // ============================================================

  Widget _settingTile({
    required IconData icon,
    required Color iconBackground,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            15,
            14,
            13,
            14,
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: _darkGreen,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _forestText,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: _mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 21,
                    color: _mutedText,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 73,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: _paleMint.withOpacity(0.8),
      ),
    );
  }

  // ============================================================
  // VALUE PILL
  // ============================================================

  Widget _valuePill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: _paleMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: _darkGreen,
        ),
      ),
    );
  }

  // ============================================================
  // WELLNESS NOTE
  // ============================================================

  Widget _wellnessNote() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _freshMint,
            _paleMint,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _celadon,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Center(
              child: Text(
                '🌱',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A gentle reminder',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _forestText,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'There is no perfect way to feel. '
                  'MindSphere is simply here to help you notice, reflect, and understand yourself a little better.',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.45,
                    color: _mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: OutlinedButton.icon(
        onPressed: () async {
          await AuthService().logout();

          if (!context.mounted) return;

          Navigator.of(context).popUntil(
            (route) => route.isFirst,
          );
        },
        icon: const Icon(
          Icons.logout_rounded,
          size: 17,
        ),
        label: const Text(
          'Log out',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkGreen,
          side: BorderSide(
            color: _celadon,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}


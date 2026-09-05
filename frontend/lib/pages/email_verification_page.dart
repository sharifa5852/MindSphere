import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_shell.dart';
import '../services/auth_service.dart';
import 'welcome_page.dart';

const _mintPrimary = Color(0xFFBFE3C0);
const _mintFresh = Color(0xFFC9EACB);
const _greenDark = Color(0xFF2D6A4F);
const _greenDarkLight = Color(0xFF3F8264);
const _forestText = Color(0xFF1B4332);
const _inkOnLight = Color(0xFF13291D);
const _mutedOnLight = Color(0xFF5B7568);
const _mintPaper = Color(0xFFF3FAF5);

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final AuthService _authService = AuthService();
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _forestText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown -= 1;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _resendEmail() async {
    if (_isResending || _resendCooldown > 0) return;
    setState(() => _isResending = true);
    try {
      await _authService.sendEmailVerification();
      if (!mounted) return;
      _showMessage('Verification email sent. Please check your inbox.');
      _startCooldown();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not send the email right now. Please try again shortly.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerified() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final isVerified = await _authService.reloadAndCheckVerified();
      if (!mounted) return;
      if (isVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppShell()),
        );
      } else {
        _showMessage('Not verified yet. Please click the link in your email first.');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not check verification status. Please try again.');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'your email';
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 375).clamp(0.85, 1.15);

    return Scaffold(
      backgroundColor: _mintPaper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 78 * scale,
                      height: 78 * scale,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_mintPrimary, _mintFresh],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _mintPrimary.withOpacity(0.5),
                            blurRadius: 26,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(child: Text('📩', style: TextStyle(fontSize: 36 * scale))),
                    ),
                  ),
                  SizedBox(height: 22),
                  Text(
                    'Check your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27 * scale,
                      fontWeight: FontWeight.w800,
                      color: _forestText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We sent a verification link to\n$email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14 * scale, height: 1.5, color: _mutedOnLight),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click the link, then come back and tap "I\'ve verified" below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13 * scale, height: 1.5, color: _mutedOnLight),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(color: _forestText.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 14)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [_greenDark, _greenDarkLight],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(color: _greenDark.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10)),
                              ],
                            ),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _isChecking ? null : _checkVerified,
                              child: _isChecking
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    )
                                  : Text("I've verified — continue", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15 * scale)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _greenDark,
                              side: const BorderSide(color: _mintFresh, width: 1.6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: (_isResending || _resendCooldown > 0) ? null : _resendEmail,
                            child: Text(
                              _resendCooldown > 0 ? 'Resend available in ${_resendCooldown}s' : 'Resend verification email',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14 * scale),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: _logout,
                      child: Text(
                        'Use a different account',
                        style: TextStyle(color: _mutedOnLight, fontWeight: FontWeight.w700, fontSize: 13 * scale),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
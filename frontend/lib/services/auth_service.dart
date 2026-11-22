import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    Duration timeout = const Duration(seconds: 30),
  })  : _auth = auth ?? FirebaseAuth.instance,
        _timeout = timeout;

  final FirebaseAuth _auth;
  final Duration _timeout;

  Future<T> _withTimeout<T>(Future<T> request) => request.timeout(
        _timeout,
        onTimeout: () => throw FirebaseAuthException(
          code: 'network-request-failed',
          message: 'The authentication service did not respond in time.',
        ),
      );

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _withTimeout(_auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ));
  }

  // Login with email and password
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _withTimeout(_auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ));
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Currently logged-in user
  User? get currentUser {
    return _auth.currentUser;
  }

  // Sends a verification email to the currently signed-in user, if not
  // already verified. Safe to call multiple times (e.g. from a "resend" button).
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await _withTimeout(user.sendEmailVerification());
    }
  }

  // Reloads the current user's data from Firebase (picks up emailVerified
  // changes made by clicking the link) and returns the fresh verified status.
  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await _withTimeout(user.reload());
    return _auth.currentUser?.emailVerified ?? false;
  }
}

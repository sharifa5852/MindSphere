import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsphere/services/auth_service.dart';

class _Credential extends Fake implements UserCredential {}

class _FirebaseAuth extends Fake implements FirebaseAuth {
  Future<UserCredential> Function(String, String)? signIn;
  Future<UserCredential> Function(String, String)? register;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      signIn!(email, password);

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      register!(email, password);
}

void main() {
  test('Firebase sign-in returns its credential without waiting for a backend',
      () async {
    final credential = _Credential();
    final auth = _FirebaseAuth()
      ..signIn = (email, password) async {
        expect(email, 'student@example.test');
        expect(password, 'test-password');
        return credential;
      };
    expect(
        await AuthService(auth: auth).login(
          email: ' student@example.test ',
          password: 'test-password',
        ),
        same(credential));
  });

  test('Firebase signup errors remain authentication errors', () async {
    final error = FirebaseAuthException(code: 'email-already-in-use');
    final auth = _FirebaseAuth()..register = (_, __) => Future.error(error);
    await expectLater(
        AuthService(auth: auth).signUp(
          email: 'student@example.test',
          password: 'test-password',
        ),
        throwsA(same(error)));
  });

  test('an unresponsive authentication request reports a bounded network error',
      () async {
    final auth = _FirebaseAuth()
      ..signIn = (_, __) => Completer<UserCredential>().future;
    await expectLater(
        AuthService(auth: auth, timeout: Duration.zero).login(
          email: 'student@example.test',
          password: 'test-password',
        ),
        throwsA(isA<FirebaseAuthException>().having(
          (error) => error.code,
          'code',
          'network-request-failed',
        )));
  });
}

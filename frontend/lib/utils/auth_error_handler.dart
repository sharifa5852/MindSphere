String getAuthErrorMessage(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'An account already exists with this email.';

    case 'invalid-email':
      return 'Please enter a valid email address.';

    case 'weak-password':
      return 'Password is too weak. Please use a stronger password.';

    case 'user-not-found':
      return 'No account was found with this email.';

    case 'wrong-password':
      return 'Incorrect password.';

    case 'invalid-credential':
      return 'Incorrect email or password.';

    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';

    case 'network-request-failed':
      return 'Network error. Check your internet connection.';

    default:
      return 'Authentication failed. Please try again.';
  }
}
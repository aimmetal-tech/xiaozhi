class AuthCredentials {
  const AuthCredentials({required this.email, required this.password});

  final String email;
  final String password;

  /// Returns a copy with trimmed email so the service always gets clean input.
  AuthCredentials normalized() {
    return AuthCredentials(email: email.trim(), password: password);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xiaozhi/models/auth/auth_credentials.dart';
import 'package:xiaozhi/services/auth/auth_service.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<User?> signInWithEmailAndPassword(AuthCredentials credentials) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await authService.signIn(credentials);
      return FirebaseAuth.instance.currentUser;
    });
    state = result;
    return result.value;
  }

  Future<User?> registerWithEmailAndPassword(
    AuthCredentials credentials,
  ) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await authService.register(credentials);
      return FirebaseAuth.instance.currentUser;
    });
    state = result;
    return result.value;
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await FirebaseAuth.instance.signOut();
      return null;
    });
    state = result;
  }
}

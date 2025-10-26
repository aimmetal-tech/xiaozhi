import 'package:firebase_auth/firebase_auth.dart';
import 'package:xiaozhi/models/auth/auth_credentials.dart';
import 'package:xiaozhi/models/auth/auth_failure.dart';
import 'package:xiaozhi/services/logger_service.dart';

class AuthService {
  const AuthService(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  Future<void> signIn(AuthCredentials credentials) async {
    final normalized = credentials.normalized();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: normalized.email,
        password: normalized.password,
      );
    } on FirebaseAuthException catch (e) {
      logger.e(
        '邮箱登录失败(FirebaseAuthException)',
        error: e,
        stackTrace: e.stackTrace,
      );
      throw AuthFailure(_mapAuthError(e, forRegister: false), code: e.code);
    } catch (e, st) {
      logger.e('邮箱登录失败(未知异常)', error: e, stackTrace: st);
      throw const AuthFailure('登录失败，请稍后再试');
    }
  }

  Future<void> register(AuthCredentials credentials) async {
    final normalized = credentials.normalized();
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalized.email,
        password: normalized.password,
      );
    } on FirebaseAuthException catch (e) {
      logger.e(
        '邮箱注册失败(FirebaseAuthException)',
        error: e,
        stackTrace: e.stackTrace,
      );
      throw AuthFailure(_mapAuthError(e, forRegister: true), code: e.code);
    } catch (e, st) {
      logger.e('邮箱注册失败(未知异常)', error: e, stackTrace: st);
      throw const AuthFailure('注册失败，请稍后再试');
    }
  }
}

final authService = AuthService(FirebaseAuth.instance);

String _mapAuthError(
  FirebaseAuthException exception, {
  required bool forRegister,
}) {
  switch (exception.code) {
    case 'invalid-email':
      return '邮箱格式不正确';
    case 'user-disabled':
      return '账户已被禁用，请联系管理员';
    case 'user-not-found':
      return '账户不存在，请先注册';
    case 'wrong-password':
      return '密码错误，请重试';
    case 'weak-password':
      return '密码太弱，请至少使用 6 位字符';
    case 'email-already-in-use':
      return '邮箱已注册，请直接登录';
    case 'operation-not-allowed':
    case 'configuration-not-found':
      return 'Firebase 控制台未启用邮箱密码登录，请先在 Authentication 的 Sign-in method 中开启';
    case 'unknown':
      final message = exception.message ?? '';
      if (message.contains('CONFIGURATION_NOT_FOUND')) {
        return 'Firebase 控制台未启用邮箱密码登录，请先在 Authentication 的 Sign-in method 中开启';
      }
      if (message.isNotEmpty) {
        return message;
      }
      return forRegister ? '注册失败，请稍后再试' : '登录失败，请稍后再试';
    default:
      if (exception.message != null && exception.message!.isNotEmpty) {
        return exception.message!;
      }
      return forRegister ? '注册失败，请稍后再试' : '登录失败，请稍后再试';
  }
}

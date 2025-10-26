import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:xiaozhi/utils/toast.dart';
import 'package:xiaozhi/services/logger_service.dart';
import 'package:xiaozhi/routes/route_config.dart';

String _mapAuthError(FirebaseAuthException e, {required bool forRegister}) {
  switch (e.code) {
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
      return 'Firebase 控制台未启用邮箱密码登录，请先在 Authentication → Sign-in method 中开启';
    case 'unknown':
      final message = e.message ?? '';
      if (message.contains('CONFIGURATION_NOT_FOUND')) {
        return 'Firebase 控制台未启用邮箱密码登录，请先在 Authentication → Sign-in method 中开启';
      }
      if (message.isNotEmpty) {
        return message;
      }
      return forRegister ? '注册失败，请稍后再试' : '登录失败，请稍后再试';
    default:
      if (e.message != null && e.message!.isNotEmpty) {
        return e.message!;
      }
      return forRegister ? '注册失败，请稍后再试' : '登录失败，请稍后再试';
  }
}

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({super.key});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      context.pop();
    } on FirebaseAuthException catch (e) {
      logger.e(
        '邮箱登录失败(FirebaseAuthException)',
        error: e,
        stackTrace: e.stackTrace,
      );
      final msg = _mapAuthError(e, forRegister: false);
      ToastUtil.show(msg: msg);
    } catch (e, st) {
      logger.e('邮箱登录失败(未知异常)', error: e, stackTrace: st);
      ToastUtil.show(msg: '登录失败，请稍后再试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('邮箱登录'),
        actions: [
          TextButton(
            onPressed: () {
              context.pushNamed(AppRouteNames.authRegister);
            },
            child: const Text('注册'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '邮箱'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '密码'),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _login,
                  icon: const Icon(Icons.login),
                  label: const Text('登录'),
                ),
              ],
            ),
          ),
          if (_loading) const _AuthLoadingOverlay(),
        ],
      ),
    );
  }
}

class AuthRegisterPage extends StatefulWidget {
  const AuthRegisterPage({super.key});

  @override
  State<AuthRegisterPage> createState() => _AuthRegisterPageState();
}

class _AuthRegisterPageState extends State<AuthRegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      ToastUtil.show(msg: '注册成功，请登录');
      context.pop();
    } on FirebaseAuthException catch (e) {
      logger.e(
        '邮箱注册失败(FirebaseAuthException)',
        error: e,
        stackTrace: e.stackTrace,
      );
      final msg = _mapAuthError(e, forRegister: true);
      ToastUtil.show(msg: msg);
    } catch (e, st) {
      logger.e('邮箱注册失败(未知异常)', error: e, stackTrace: st);
      ToastUtil.show(msg: '注册失败，请稍后再试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('邮箱注册')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '邮箱'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '密码（至少6位）'),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _register,
                  icon: const Icon(Icons.person_add),
                  label: const Text('注册'),
                ),
              ],
            ),
          ),
          if (_loading) const _AuthLoadingOverlay(),
        ],
      ),
    );
  }
}

class _AuthLoadingOverlay extends StatelessWidget {
  const _AuthLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      color: Colors.black45,
      child: Center(child: SpinKitCircle(color: color, size: 48)),
    );
  }
}

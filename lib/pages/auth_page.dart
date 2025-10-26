import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:xiaozhi/models/auth/auth_credentials.dart';
import 'package:xiaozhi/models/auth/auth_failure.dart';
import 'package:xiaozhi/routes/route_config.dart';
import 'package:xiaozhi/services/auth/auth_service.dart';
import 'package:xiaozhi/services/logger_service.dart';
import 'package:xiaozhi/utils/toast.dart';

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
      await authService.signIn(
        AuthCredentials(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
      if (!mounted) return;
      context.pop();
    } on AuthFailure catch (e) {
      ToastUtil.show(msg: e.message);
    } catch (e, st) {
      logger.e('邮箱登录失败(页面异常)', error: e, stackTrace: st);
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
      await authService.register(
        AuthCredentials(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
      if (!mounted) return;
      ToastUtil.show(msg: '注册成功，请登录');
      context.pop();
    } on AuthFailure catch (e) {
      ToastUtil.show(msg: e.message);
    } catch (e, st) {
      logger.e('邮箱注册失败(页面异常)', error: e, stackTrace: st);
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
                  decoration: const InputDecoration(labelText: '密码（至少 6 位）'),
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

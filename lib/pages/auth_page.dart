import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:xiaozhi/models/auth/auth_credentials.dart';
import 'package:xiaozhi/models/auth/auth_failure.dart';
import 'package:xiaozhi/provider/auth_provider.dart';
import 'package:xiaozhi/routes/route_config.dart';
import 'package:xiaozhi/utils/toast.dart';

class AuthLoginPage extends ConsumerStatefulWidget {
  const AuthLoginPage({super.key});

  @override
  ConsumerState<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends ConsumerState<AuthLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _errorMessage(Object error) {
    if (error is AuthFailure) {
      return error.message;
    }
    return '登录失败，请稍后再试';
  }

  Future<void> signIn() async {
    await ref.read(authProvider.notifier).signInWithEmailAndPassword(
      AuthCredentials(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && mounted) {
            context.pop();
          }
        },
        error: (error, stackTrace) {
          ToastUtil.show(msg: _errorMessage(error));
        },
      );
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
              crossAxisAlignment: .stretch,
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
                  onPressed: isLoading ? null : signIn,
                  icon: const Icon(Icons.login),
                  label: const Text('登录'),
                ),
              ],
            ),
          ),
          if (isLoading) const _AuthLoadingOverlay(),
        ],
      ),
    );
  }
}

class AuthRegisterPage extends ConsumerStatefulWidget {
  const AuthRegisterPage({super.key});

  @override
  ConsumerState<AuthRegisterPage> createState() => _AuthRegisterPageState();
}

class _AuthRegisterPageState extends ConsumerState<AuthRegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _errorMessage(Object error) {
    if (error is AuthFailure) {
      return error.message;
    }
    return '注册失败，请稍后再试';
  }

  Future<void> _register() async {
    await ref.read(authProvider.notifier).registerWithEmailAndPassword(
          AuthCredentials(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && mounted) {
            ToastUtil.show(msg: '注册成功，请登录');
            context.pop();
          }
        },
        error: (error, stackTrace) {
          ToastUtil.show(msg: _errorMessage(error));
        },
      );
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
                  onPressed: isLoading ? null : _register,
                  icon: const Icon(Icons.person_add),
                  label: const Text('注册'),
                ),
              ],
            ),
          ),
          if (isLoading) const _AuthLoadingOverlay(),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lesser/core/utils/snackbar.dart';
import 'package:lesser/core/validation/validators.dart';
import 'package:lesser/features/auth/presentation/providers/auth_provider.dart';
import 'package:lesser/features/auth/presentation/screens/register_screen.dart';
import 'package:lesser/features/auth/domain/models/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty) {
      setState(() => _localError = '请输入用户名或邮箱');
      return false;
    }

    if (password.isEmpty) {
      setState(() => _localError = '请输入密码');
      return false;
    }

    if (username.contains('@')) {
      final emailError = Validators.validateEmail(username);
      if (emailError != null) {
        setState(() => _localError = emailError);
        return false;
      }
    }

    if (password.length < 8) {
      setState(() => _localError = '密码长度至少为8个字符');
      return false;
    }

    setState(() => _localError = null);
    return true;
  }

  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    await ref.read(authProvider.notifier).login(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
          if (mounted) Navigator.pushReplacementNamed(context, '/main');
        },
        unauthenticated: () {},
        error: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(CustomSnackBar.error(message: message));
          }
        },
      );
    });

    final isLoading = authState is AuthStateLoading;
    final authError = authState is AuthStateError ? authState.message : null;
    final displayError = _localError ?? authError;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Lesser',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '记录生活的每一个瞬间',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: _usernameController,
                  ),
                  label: const Text('用户名'),
                  hint: '请输入用户名',
                  enabled: !isLoading,
                ),
                const SizedBox(height: 20),
                FTextField.password(
                  control: FTextFieldControl.managed(
                    controller: _passwordController,
                  ),
                  label: const Text('密码'),
                  hint: '请输入密码',
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),
                if (displayError != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF5252)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFFF5252),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayError,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFFF5252),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FButton(
                    onPress: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('登录'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '还没有账号？',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              ),
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(
                          const Color(0xFFEE1D52),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      child: const Text('立即注册'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

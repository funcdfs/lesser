import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/core/utils/snackbar.dart';
import 'package:lesser/core/validation/validators.dart';
import 'package:lesser/features/auth/presentation/providers/auth_provider.dart';
import 'package:lesser/features/auth/presentation/screens/register_screen.dart';
import 'package:lesser/features/auth/domain/models/auth_state.dart';
import 'package:lesser/shared/widgets/app_button.dart';
import 'package:lesser/shared/widgets/app_input.dart';
import 'package:lesser/shared/theme/colors.dart';
import 'package:lesser/shared/theme/spacing.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'funcdfs');
  final TextEditingController _passwordController =
      TextEditingController(text: 'fw142857');
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Lesser',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '记录生活的每一个瞬间',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 48),
                // 用户名输入框
                AppInput(
                  controller: _usernameController,
                  labelText: '用户名',
                  hintText: '请输入用户名',
                  isReadOnly: isLoading,
                ),
                const SizedBox(height: 20),
                // 密码输入框
                AppInput.password(
                  controller: _passwordController,
                  labelText: '密码',
                  hintText: '请输入密码',
                  isReadOnly: isLoading,
                ),
                const SizedBox(height: 24),
                if (displayError != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayError,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // 登录按钮 - 使用 AppButton
                AppButton.primary(
                  text: '登录',
                  onPressed: isLoading ? null : _handleLogin,
                  isLoading: isLoading,
                  isBlock: true,
                  size: AppButtonSize.large,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '还没有账号？',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    // 注册按钮 - 使用 AppButton.text
                    AppButton.text(
                      text: '立即注册',
                      onPressed: isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              ),
                      size: AppButtonSize.medium,
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

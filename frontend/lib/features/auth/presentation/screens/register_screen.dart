import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/core/utils/snackbar.dart';
import 'package:lesser/core/validation/validators.dart';
import 'package:lesser/features/auth/presentation/providers/auth_provider.dart';
import 'package:lesser/features/auth/domain/models/auth_state.dart';
import 'package:lesser/shared/widgets/app_button.dart';
import 'package:lesser/shared/widgets/app_input.dart';
import 'package:lesser/shared/theme/colors.dart';
import 'package:lesser/shared/theme/spacing.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final usernameError = Validators.validateUsername(username);
    if (usernameError != null) {
      setState(() => _localError = usernameError);
      return false;
    }

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      setState(() => _localError = emailError);
      return false;
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      setState(() => _localError = passwordError);
      return false;
    }

    final confirmError = Validators.validatePasswordConfirm(
      password,
      confirmPassword,
    );
    if (confirmError != null) {
      setState(() => _localError = confirmError);
      return false;
    }

    setState(() => _localError = null);
    return true;
  }

  Future<void> _handleRegister() async {
    if (!_validateInputs()) return;

    await ref.read(authProvider.notifier).register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
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
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(CustomSnackBar.success(message: '注册成功'));
            Navigator.pushReplacementNamed(context, '/main');
          }
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
                const SizedBox(height: 40),
                // 用户名输入框
                AppInput(
                  controller: _usernameController,
                  labelText: '用户名',
                  hintText: '请输入用户名',
                  isReadOnly: isLoading,
                ),
                const SizedBox(height: 16),
                // 邮箱输入框
                AppInput(
                  controller: _emailController,
                  labelText: '邮箱',
                  hintText: '请输入邮箱',
                  isReadOnly: isLoading,
                ),
                const SizedBox(height: 16),
                // 密码输入框
                AppInput.password(
                  controller: _passwordController,
                  labelText: '密码',
                  hintText: '请输入密码',
                  isReadOnly: isLoading,
                ),
                const SizedBox(height: 16),
                // 确认密码输入框
                AppInput.password(
                  controller: _confirmPasswordController,
                  labelText: '确认密码',
                  hintText: '请再次输入密码',
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
                // 注册按钮 - 使用 AppButton
                AppButton.primary(
                  text: '注册',
                  onPressed: isLoading ? null : _handleRegister,
                  isLoading: isLoading,
                  isBlock: true,
                  size: AppButtonSize.large,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '已有账号？',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    // 登录按钮 - 使用 AppButton.text
                    AppButton.text(
                      text: '立即登录',
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                                context,
                                '/login',
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

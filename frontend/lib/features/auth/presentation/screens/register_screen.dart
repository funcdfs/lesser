import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lesser/core/utils/snackbar.dart';
import 'package:lesser/core/validation/validators.dart';
import 'package:lesser/features/auth/presentation/providers/auth_provider.dart';
import 'package:lesser/features/auth/domain/models/auth_state.dart';

/// 注册界面 - 使用 AuthProvider 进行状态管理
/// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 7.1, 7.2
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _localError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 验证输入字段 (Requirements: 1.2, 1.4)
  bool _validateInputs() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate username
    final usernameError = Validators.validateUsername(username);
    if (usernameError != null) {
      setState(() => _localError = usernameError);
      return false;
    }

    // Validate email
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      setState(() => _localError = emailError);
      return false;
    }

    // Validate password
    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      setState(() => _localError = passwordError);
      return false;
    }

    // Validate confirm password
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

  /// 处理注册 (Requirements: 1.1, 1.5, 1.6)
  Future<void> _handleRegister() async {
    if (!_validateInputs()) return;

    await ref
        .read(authProvider.notifier)
        .register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // 监听认证状态变化 (Requirements: 1.6, 7.1, 7.2)
    ref.listen<AuthState>(authProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(CustomSnackBar.success(message: '注册成功'));
            Navigator.pushReplacementNamed(context, '/main');
          }
        },
        unauthenticated: () {},
        error: (message) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(CustomSnackBar.error(message: message));
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
                const SizedBox(height: 40),
                // 用户名
                FTextField(
                  controller: _usernameController,
                  label: const Text('用户名'),
                  hint: '请输入用户名',
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                // 邮箱
                FTextField(
                  controller: _emailController,
                  label: const Text('邮箱'),
                  hint: '请输入邮箱',
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // 密码
                FTextField(
                  controller: _passwordController,
                  label: const Text('密码'),
                  hint: '请输入密码',
                  obscureText: _obscurePassword,
                  enabled: !isLoading,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),
                // 确认密码
                FTextField(
                  controller: _confirmPasswordController,
                  label: const Text('确认密码'),
                  hint: '请再次输入密码',
                  obscureText: _obscureConfirmPassword,
                  enabled: !isLoading,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 错误信息显示 (Requirements 7.1, 7.2)
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
                // 注册按钮
                SizedBox(
                  width: double.infinity,
                  child: FButton(
                    onPress: isLoading ? null : _handleRegister,
                    label: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('注册'),
                  ),
                ),
                const SizedBox(height: 24),
                // 登录链接
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '已有账号？',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
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
                      child: const Text('立即登录'),
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

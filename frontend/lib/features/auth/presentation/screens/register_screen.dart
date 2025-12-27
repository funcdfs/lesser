import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lesser/core/utils/snackbar.dart';
import 'package:lesser/core/validation/validators.dart';
import 'package:lesser/features/auth/presentation/providers/auth_provider.dart';
import 'package:lesser/features/auth/domain/models/auth_state.dart';

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
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: _usernameController,
                  ),
                  label: const Text('用户名'),
                  hint: '请输入用户名',
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: _emailController,
                  ),
                  label: const Text('邮箱'),
                  hint: '请输入邮箱',
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                FTextField.password(
                  control: FTextFieldControl.managed(
                    controller: _passwordController,
                  ),
                  label: const Text('密码'),
                  hint: '请输入密码',
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                FTextField.password(
                  control: FTextFieldControl.managed(
                    controller: _confirmPasswordController,
                  ),
                  label: const Text('确认密码'),
                  hint: '请再次输入密码',
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
                    onPress: isLoading ? null : _handleRegister,
                    child: isLoading
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

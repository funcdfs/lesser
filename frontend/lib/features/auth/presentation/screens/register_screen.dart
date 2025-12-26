import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/core/network/token_manager.dart';
import 'package:logger/logger.dart';

final logger = Logger();

// 注册界面
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final password1 = _password1Controller.text.trim();
    final password2 = _password2Controller.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty ||
        password1.isEmpty ||
        password2.isEmpty ||
        email.isEmpty) {
      setState(() {
        _errorMessage = '请填写所有必填字段';
      });
      return;
    }

    if (password1 != password2) {
      setState(() {
        _errorMessage = '两次输入的密码不一致';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 使用provider获取ApiClient实例
      final apiClient = ref.watch(apiClientProvider);

      final response = await apiClient.apiService.register({
        'username': username,
        'email': email,
        'password': password1,
      });

      logger.i('注册响应: ${response.body}, 状态码: ${response.statusCode}');

      // 检查响应是否成功
      if (response.isSuccessful && response.body != null) {
        // 保存认证令牌
        final token = response.body['token'];
        if (token != null) {
          await TokenManager.saveToken(token);
          logger.i('Token保存成功');
        }

        // 注册成功后导航到主页
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('注册成功')));
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // 处理API返回的错误
        logger.e(
          '注册失败 - API错误: ${response.statusCode}, 错误信息: ${response.body}',
        );
        setState(() {
          _errorMessage = response.body?['error'] ?? '注册失败，请稍后重试';
        });
      }
    } catch (e) {
      logger.e('注册失败 - 异常: $e');
      setState(() {
        _errorMessage = '注册失败，请检查网络连接或稍后重试';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FTheme(
      data: FThemeData.light(),
      child: FScaffold(
        backgroundColor: Colors.white,
        content: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Logo和应用名称
                  const FText(
                    'Lesser',
                    style: FTextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const FText(
                    '记录生活的每一个瞬间',
                    style: FTextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // 注册表单
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FText(
                        '用户名',
                        style: FTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FInput(
                        controller: _usernameController,
                        placeholder: '请输入用户名',
                        style: const FInputStyle(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          backgroundColor: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderWidth: 0,
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const FText(
                        '邮箱',
                        style: FTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FInput(
                        controller: _emailController,
                        placeholder: '请输入邮箱',
                        style: const FInputStyle(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          backgroundColor: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderWidth: 0,
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const FText(
                        '密码',
                        style: FTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FInput(
                        controller: _password1Controller,
                        placeholder: '请输入密码',
                        obscureText: _obscurePassword,
                        style: const FInputStyle(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          backgroundColor: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderWidth: 0,
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      const FText(
                        '确认密码',
                        style: FTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FInput(
                        controller: _password2Controller,
                        placeholder: '请再次输入密码',
                        obscureText: _obscurePassword,
                        style: const FInputStyle(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          backgroundColor: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderWidth: 0,
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 显示错误信息
                      if (_errorMessage.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFF5252)),
                          ),
                          child: FText(
                            _errorMessage,
                            style: const FTextStyle(
                              fontSize: 14,
                              color: Color(0xFFFF5252),
                            ),
                          ),
                        ),

                      // 注册按钮
                      FButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: const FButtonStyle(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Color(0xFFEE1D52),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        child: _isLoading
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
                      const SizedBox(height: 16),

                      // 登录链接
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FText(
                            '已有账号？',
                            style: FTextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const FText(
                              '立即登录',
                              style: FTextStyle(
                                fontSize: 14,
                                color: Color(0xFFEE1D52),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

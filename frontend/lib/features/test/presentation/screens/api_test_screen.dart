import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/core/network/api_endpoints.dart';
import 'package:lesser/shared/theme/theme.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ApiTestScreen extends ConsumerStatefulWidget {
  const ApiTestScreen({super.key});

  @override
  ConsumerState<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends ConsumerState<ApiTestScreen> {
  String _result = '点击按钮测试API';
  bool _loading = false;
  String _error = '';

  Future<void> _testApi() async {
    setState(() {
      _loading = true;
      _error = '';
      _result = '测试中...';
    });

    try {
      final apiClient = ApiClient();

      // 测试用户登录 API (使用已存在的用户)
      logger.i('请求URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.login}');
      logger.i('请求数据: {username: testuser5, password: testpassword123}');
      final loginResponse = await apiClient.apiService.login({
        'username': 'testuser5',
        'password': 'testpassword123',
      });

      logger.i('登录成功: ${loginResponse.body}');
      _result = '登录成功: ${loginResponse.body}';
    } catch (e) {
      logger.e('API测试失败: $e');
      setState(() {
        _error = 'API测试失败: $e';
        _result = '点击按钮重新测试';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _loading = true;
      _error = '';
      _result = '登录测试中...';
    });

    try {
      final apiClient = ApiClient();

      // 测试用户登录 API
      final loginResponse = await apiClient.apiService.login({
        'username': 'testuser5',
        'password': 'testpassword123',
      });

      logger.i('登录成功: ${loginResponse.body}');
      _result = '登录成功: ${loginResponse.body}';
    } catch (e) {
      logger.e('登录测试失败: $e');
      setState(() {
        _error = '登录测试失败: $e';
        _result = '点击按钮重新测试';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API测试页面'),
        backgroundColor: AppColors.background,
        elevation: 1,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Text(
                        'API测试结果',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _result,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      if (_error.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.destructive.withValues(
                              alpha: 0.1 * 255,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.destructive),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _error,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.destructive),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _loading ? null : _testApi,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('测试用户注册'),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _loading ? null : _testLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('测试用户登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

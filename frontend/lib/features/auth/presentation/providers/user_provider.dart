import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/features/auth/data/user_repository.dart';
import 'package:lesser/features/auth/domain/models/user.dart';
import 'package:lesser/core/config/debug_config.dart';

part 'user_provider.g.dart';

@riverpod
UserRepository userRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRepository(apiClient);
}

@riverpod
Future<User> currentUser(Ref ref) async {
  if (DebugConfig.debugLocal) {
    // 纯前端调试模式：返回fake数据
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    return User(
      id: 1,
      username: 'debug_user',
      email: 'debug@example.com',
      firstName: 'Debug',
      lastName: 'User',
    );
  } else {
    // 前后端联动调试模式：调用API获取真实数据
    final repository = ref.watch(userRepositoryProvider);
    return repository.getProfile();
  }
}

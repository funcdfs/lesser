import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/features/auth/data/user_repository.dart';
import 'package:lesser/features/auth/domain/models/user.dart';

part 'user_provider.g.dart';

@riverpod
UserRepository userRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRepository(apiClient);
}

@riverpod
Future<User> currentUser(Ref ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getProfile();
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_client.dart';
import 'chopper_api_service.dart';

part 'api_provider.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient();
}

@Riverpod(keepAlive: true)
ChopperApiService chopperApiService(ChopperApiServiceRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.apiService;
}

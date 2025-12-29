import 'package:grpc/grpc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// gRPC 客户端管理器
/// 提供统一的 gRPC 连接管理和认证拦截
class GrpcClientManager {
  GrpcClientManager({
    required FlutterSecureStorage secureStorage,
    String? host,
    int? port,
  })  : _secureStorage = secureStorage,
        _host = host ?? AppConstants.grpcHost,
        _port = port ?? AppConstants.grpcPort;

  final FlutterSecureStorage _secureStorage;
  final String _host;
  final int _port;
  ClientChannel? _channel;

  /// 获取或创建 gRPC channel
  ClientChannel get channel {
    _channel ??= ClientChannel(
      _host,
      port: _port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: AppConstants.connectionTimeout,
        idleTimeout: Duration(minutes: 5),
      ),
    );
    return _channel!;
  }

  /// 获取带认证的 CallOptions
  Future<CallOptions> getAuthCallOptions() async {
    final token = await _secureStorage.read(key: 'access_token');
    return CallOptions(
      metadata: {
        if (token != null) 'authorization': 'Bearer $token',
      },
      timeout: AppConstants.receiveTimeout,
    );
  }

  /// 创建带认证拦截器的 stub
  T createStub<T>(T Function(ClientChannel, Iterable<ClientInterceptor>) factory) {
    return factory(channel, [AuthInterceptor(_secureStorage)]);
  }

  /// 关闭连接
  Future<void> shutdown() async {
    await _channel?.shutdown();
    _channel = null;
  }

  /// 终止连接
  Future<void> terminate() async {
    await _channel?.terminate();
    _channel = null;
  }
}

/// 认证拦截器
class AuthInterceptor extends ClientInterceptor {
  AuthInterceptor(FlutterSecureStorage secureStorage)
      : _secureStorage = secureStorage;

  // ignore: unused_field
  final FlutterSecureStorage _secureStorage;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    return invoker(method, request, _addAuthMetadata(options));
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    return invoker(method, requests, _addAuthMetadata(options));
  }

  CallOptions _addAuthMetadata(CallOptions options) {
    // 注意：此处是同步的，token 需要预先加载
    // 实际使用时建议通过 getAuthCallOptions() 异步获取
    return options;
  }
}

/// gRPC 错误处理工具
class GrpcErrorHandler {
  static String getErrorMessage(GrpcError error) {
    switch (error.code) {
      case StatusCode.unauthenticated:
        return '认证失败，请重新登录';
      case StatusCode.permissionDenied:
        return '权限不足';
      case StatusCode.notFound:
        return '资源不存在';
      case StatusCode.alreadyExists:
        return '资源已存在';
      case StatusCode.invalidArgument:
        return '参数无效: ${error.message}';
      case StatusCode.unavailable:
        return '服务暂时不可用，请稍后重试';
      case StatusCode.deadlineExceeded:
        return '请求超时，请检查网络连接';
      case StatusCode.internal:
        return '服务器内部错误';
      default:
        return error.message ?? '未知错误';
    }
  }

  static void logError(GrpcError error, {String? context}) {
    log.e(
      '${context ?? "gRPC"} 错误: [${error.code}] ${error.message}',
      tag: 'gRPC',
    );
  }
}

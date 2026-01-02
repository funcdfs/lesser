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
  }) : _secureStorage = secureStorage,
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
        if (log.traceId != null) 'x-trace-id': log.traceId!,
      },
      timeout: AppConstants.receiveTimeout,
    );
  }

  /// 创建带认证拦截器的 stub
  T createStub<T>(
    T Function(ClientChannel, Iterable<ClientInterceptor>) factory,
  ) {
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

/// gRPC 错误转换器
/// 将 gRPC 错误码转换为用户友好的提示信息
class GrpcErrorConverter {
  /// 转换 gRPC 错误为用户友好消息
  static String toUserMessage(GrpcError error) {
    return GrpcErrorHandler.getErrorMessage(error);
  }

  /// 转换 gRPC 状态码为用户友好消息
  static String statusCodeToMessage(StatusCode code, {String? details}) {
    switch (code) {
      case StatusCode.ok:
        return '操作成功';
      case StatusCode.cancelled:
        return '操作已取消';
      case StatusCode.unknown:
        return details ?? '发生未知错误';
      case StatusCode.invalidArgument:
        return details != null ? '参数无效: $details' : '请求参数无效';
      case StatusCode.deadlineExceeded:
        return '请求超时，请检查网络连接';
      case StatusCode.notFound:
        return details ?? '请求的资源不存在';
      case StatusCode.alreadyExists:
        return details ?? '资源已存在';
      case StatusCode.permissionDenied:
        return '您没有权限执行此操作';
      case StatusCode.resourceExhausted:
        return '请求过于频繁，请稍后再试';
      case StatusCode.failedPrecondition:
        return details ?? '操作前置条件不满足';
      case StatusCode.aborted:
        return '操作被中止，请重试';
      case StatusCode.outOfRange:
        return details ?? '请求参数超出有效范围';
      case StatusCode.unimplemented:
        return '该功能暂未实现';
      case StatusCode.internal:
        return '服务器内部错误，请稍后重试';
      case StatusCode.unavailable:
        return '服务暂时不可用，请稍后重试';
      case StatusCode.dataLoss:
        return '数据丢失或损坏';
      case StatusCode.unauthenticated:
        return '请先登录';
      default:
        return details ?? '发生错误，请重试';
    }
  }

  /// 判断错误是否需要重新登录
  static bool requiresReauth(GrpcError error) {
    return error.code == StatusCode.unauthenticated;
  }

  /// 判断错误是否可重试
  static bool isRetryable(GrpcError error) {
    switch (error.code) {
      case StatusCode.unavailable:
      case StatusCode.deadlineExceeded:
      case StatusCode.aborted:
      case StatusCode.resourceExhausted:
        return true;
      default:
        return false;
    }
  }

  /// 获取建议的重试延迟（毫秒）
  static int getRetryDelay(GrpcError error, int attemptNumber) {
    // 指数退避：1s, 2s, 4s, 8s, 最大 30s
    const baseDelay = 1000;
    const maxDelay = 30000;
    final delay = baseDelay * (1 << attemptNumber.clamp(0, 5));
    return delay.clamp(baseDelay, maxDelay);
  }
}

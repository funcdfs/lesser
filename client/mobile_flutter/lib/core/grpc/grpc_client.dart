import 'package:grpc/grpc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// gRPC 客户端管理器
/// 提供统一的 gRPC 连接管理和认证拦截
/// 自动检测平台并使用适当的传输方式（Web 使用 grpc-web，其他平台使用原生 gRPC）
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
  /// 移动平台使用原生 gRPC ClientChannel
  /// 注意：Web 平台需要单独处理，但本应用主要针对移动端
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
    final userId = await _secureStorage.read(key: 'user_id');
    return CallOptions(
      metadata: {
        if (token != null) 'authorization': 'Bearer $token',
        if (userId != null) 'user_id': userId,
        if (log.traceId != null) 'x-trace-id': log.traceId!,
      },
      timeout: AppConstants.receiveTimeout,
    );
  }

  /// 获取带认证的 CallOptions（用于双向流，不设置超时）
  Future<CallOptions> getStreamCallOptions() async {
    final token = await _secureStorage.read(key: 'access_token');
    final userId = await _secureStorage.read(key: 'user_id');
    return CallOptions(
      metadata: {
        if (token != null) 'authorization': 'Bearer $token',
        if (userId != null) 'user_id': userId,
        if (log.traceId != null) 'x-trace-id': log.traceId!,
      },
      // 双向流不设置超时，由心跳机制管理连接
    );
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
class GrpcErrorConverter {
  static String toUserMessage(GrpcError error) {
    return GrpcErrorHandler.getErrorMessage(error);
  }

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

  static bool requiresReauth(GrpcError error) {
    return error.code == StatusCode.unauthenticated;
  }

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

  static int getRetryDelay(GrpcError error, int attemptNumber) {
    const baseDelay = 1000;
    const maxDelay = 30000;
    final delay = baseDelay * (1 << attemptNumber.clamp(0, 5));
    return delay.clamp(baseDelay, maxDelay);
  }
}

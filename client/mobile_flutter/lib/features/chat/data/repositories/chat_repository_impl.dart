import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

const _tag = 'ChatRepo';

/// 聊天仓库实现
/// 负责协调数据源并处理错误转换
class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Conversation>>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final conversations = await _remoteDataSource.getConversations(
        page: page,
        pageSize: pageSize,
      );
      log.i('获取到 ${conversations.length} 个会话', tag: _tag);
      return Right(conversations);
    } on ServerException catch (e) {
      log.w('服务器异常: ${e.message}', tag: _tag);
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      log.w('网络异常: ${e.message}', tag: _tag);
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      log.w('未授权异常: ${e.message}', tag: _tag);
      return Left(UnauthorizedFailure(message: e.message));
    } on TimeoutException catch (e) {
      log.w('超时异常: ${e.message}', tag: _tag);
      return Left(TimeoutFailure(message: e.message));
    } catch (e, stackTrace) {
      log.e('未知错误: $e', tag: _tag, stackTrace: stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversation(
      String conversationId) async {
    try {
      final conversation =
          await _remoteDataSource.getConversation(conversationId);
      return Right(conversation);
    } on ServerException catch (e) {
      log.w('服务器异常: ${e.message}', tag: _tag);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      log.w('未找到异常: ${e.message}', tag: _tag);
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      log.w('网络异常: ${e.message}', tag: _tag);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      log.e('未知错误: $e', tag: _tag, stackTrace: stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> createConversation({
    required ConversationType type,
    required List<String> memberIds,
    String? name,
  }) async {
    try {
      final conversation = await _remoteDataSource.createConversation(
        type: type,
        memberIds: memberIds,
        name: name,
      );
      return Right(conversation);
    } on ServerException catch (e) {
      log.w('服务器异常: ${e.message}', tag: _tag);
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      log.w('网络异常: ${e.message}', tag: _tag);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      log.e('未知错误: $e', tag: _tag, stackTrace: stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final messages = await _remoteDataSource.getMessages(
        conversationId: conversationId,
        page: page,
        pageSize: pageSize,
      );
      return Right(messages);
    } on ServerException catch (e) {
      log.w('服务器异常: ${e.message}', tag: _tag);
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      log.w('网络异常: ${e.message}', tag: _tag);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      log.e('未知错误: $e', tag: _tag, stackTrace: stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    MessageType messageType = MessageType.text,
  }) async {
    try {
      final message = await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        content: content,
        messageType: messageType,
      );
      return Right(message);
    } on ServerException catch (e) {
      log.w('服务器异常: ${e.message}', tag: _tag);
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      log.w('网络异常: ${e.message}', tag: _tag);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      log.e('未知错误: $e', tag: _tag, stackTrace: stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MarkAsReadResult>> markAsRead(String conversationId) async {
    try {
      final result = await _remoteDataSource.markAsRead(conversationId);
      log.d('标记已读成功，标记了 ${result.markedCount} 条消息', tag: _tag);
      return Right(MarkAsReadResult(markedCount: result.markedCount));
    } on ServerException catch (e) {
      log.w('服务器异常: ${e.message}', tag: _tag);
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      log.w('网络异常: ${e.message}', tag: _tag);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      log.e('未知错误: $e', tag: _tag, stackTrace: stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UnreadCountResult>>> getUnreadCounts(List<String> conversationIds) async {
    try {
      final results = await _remoteDataSource.getUnreadCounts(conversationIds);
      return Right(results.map((r) => UnreadCountResult(
        conversationId: r.conversationId,
        count: r.count,
      )).toList());
    } on ServerException catch (e) {
      log.w('服务器异常: ${e.message}', tag: _tag);
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      log.w('网络异常: ${e.message}', tag: _tag);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      log.e('未知错误: $e', tag: _tag, stackTrace: stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<Message> streamMessages(String conversationId) {
    // 实时消息通过 gRPC 双向流 (ChatStreamClient) 处理
    // 此方法保留用于兼容性，实际使用 ChatRoomNotifier 中的事件监听
    return const Stream.empty();
  }
}

import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

/// Chat repository implementation
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
      return Right(conversations);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
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
      return Left(ServerFailure(message: e.message));
    } on NotFoundException {
      return const Left(NotFoundFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
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
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
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
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
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
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Stream<Message> streamMessages(String conversationId) {
    // TODO: Implement WebSocket/gRPC streaming
    // This is a placeholder that returns an empty stream
    return const Stream.empty();
  }
}

import 'package:chopper/chopper.dart';
import 'package:logger/logger.dart';

abstract class BaseRepository {
  final Logger logger = Logger();

  Future<T> safeApiCall<T>(
    Future<Response> Function() call, {
    required T Function(dynamic data) mapper,
  }) async {
    try {
      final response = await call();
      if (response.isSuccessful) {
        return mapper(response.body);
      } else {
        logger.e('API Error: ${response.statusCode}', error: response.error);
        throw _handleChopperError(response);
      }
    } catch (e) {
      logger.e('Unexpected Error', error: e);
      throw Exception('An unexpected error occurred');
    }
  }

  Exception _handleChopperError(Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 400 && statusCode < 500) {
      return Exception('Client error: $statusCode');
    } else if (statusCode >= 500) {
      return Exception('Server error: $statusCode');
    }
      return Exception('Network error occurred');
  }
}

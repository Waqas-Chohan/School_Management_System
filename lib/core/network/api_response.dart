import 'package:dio/dio.dart';

import '../error/failures.dart';
import '../result/result.dart';

/// Handles a [DioException] and translates it into an [AppFailure].
AppFailure mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return NetworkFailure('No internet connection. Please try again.');
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode;
      final message = _readServerMessage(error.response?.data);
      if (status == 401 || status == 403) {
        return UnauthorizedFailure(message ?? 'Session expired. Please login again.');
      }
      return ServerFailure(message ?? 'Something went wrong. Please try again.',
          statusCode: status);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return UnknownFailure(error.message ?? 'Unable to load data.');
    default:
      return UnknownFailure(error.message ?? 'Unable to load data.');
  }
}

String? _readServerMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'] ?? data['detail'];
    if (message != null) return message.toString();
  }
  return null;
}

/// Wraps a callback that returns a [Future] into a [Result].
Future<Result<T>> guardApi<T>(Future<T> Function() request) async {
  try {
    final data = await request();
    return Success(data);
  } on DioException catch (error) {
    return Failure(mapDioException(error));
  } catch (error) {
    return Failure(UnknownFailure(error.toString()));
  }
}
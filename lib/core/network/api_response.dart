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

/// Unwraps the SMS portal envelope `{ "success": bool, "message": str,
/// "data": ... }`. When `success` is `false` the server's message is surfaced
/// as a [ServerFailure] so the callers receive a human-readable error.
dynamic unwrapEnvelope(Object? body) {
  if (body is Map<String, dynamic>) {
    final success = body['success'];
    if (success == false) {
      throw ServerFailure(
        body['message']?.toString() ?? 'Something went wrong. Please try again.',
      );
    }
    return body['data'];
  }
  return body;
}

/// Unwraps the envelope and casts `data` to a list (empty list when absent).
List<dynamic> envelopeList(Object? body) {
  final data = unwrapEnvelope(body);
  if (data is List) return data;
  return const [];
}

/// Unwraps the envelope and casts `data` to a map (empty map when absent).
Map<String, dynamic> envelopeMap(Object? body) {
  final data = unwrapEnvelope(body);
  if (data is Map) return data.cast<String, dynamic>();
  return const <String, dynamic>{};
}

/// Wraps a callback that returns a [Future] into a [Result].
Future<Result<T>> guardApi<T>(Future<T> Function() request) async {
  try {
    final data = await request();
    return Success(data);
  } on DioException catch (error) {
    return Failure(mapDioException(error));
  } catch (error) {
    // Preserve failures already raised by our envelope unwrapping.
    if (error is AppFailure) return Failure(error);
    return Failure(UnknownFailure(error.toString()));
  }
}
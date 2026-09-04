import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_endpoints.dart';

/// Shared [FlutterSecureStorage] instance used to persist auth tokens.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

/// Global [Dio] client used by every remote data source.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ),
  );

  // Logging is enabled ONLY in debug builds, and even there it prints just a
  // compact one-line summary (method + URI + status) per request. Pretty-printing
  // full request/response bodies on the UI isolate was blocking the main thread
  // for hundreds of milliseconds (>44 skipped frames, i.e. the visible "hang").
  // In profile/release builds this block is compiled out entirely.
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        compact: true,
        maxWidth: 120,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
      ),
    );
  }

  return dio;
});

/// Exposes the current connectivity status stream.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Convenience provider mapping the connectivity stream to a single result.
final isConnectedProvider = Provider<bool>((ref) {
  final value = ref.watch(connectivityProvider).value;
  if (value == null || value.isEmpty) return false;
  return !value.contains(ConnectivityResult.none);
});
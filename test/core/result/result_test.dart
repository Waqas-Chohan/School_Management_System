import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/core/error/failures.dart';
import 'package:school_management_system/core/result/result.dart';

void main() {
  group('Result', () {
    test('Success carries data', () {
      const result = Success<int>(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('Failure carries an AppFailure', () {
      const failure = UnknownFailure('boom');
      const result = Failure<int>(failure);
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    test('fold maps success and failure', () {
      const ok = Success<int>(7);
      const err = Failure<int>(NetworkFailure('offline'));

      String show(Result<int> r) => r.fold(
            (data) => 'data:$data',
            (failure) => 'error:${failure.message}',
          );

      expect(show(ok), 'data:7');
      expect(show(err), 'error:offline');
    });

    test('dataOrNull frees the typed value', () {
      final value = const Success<int>(5).dataOrNull;
      expect(value, 5);
    });
  });
}
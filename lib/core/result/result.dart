import '../error/failures.dart';

/// A sealed result type used to represent the outcome of an operation.
///
/// Either [Success] carrying the produced [data], or [Failure] carrying the
/// [AppFailure] that occurred (and optionally a [StackTrace]).
sealed class Result<T> {
  const Result();
}

/// Represents a successful operation with its produced data.
final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// Represents a failed operation with the failure that occurred.
final class Failure<T> extends Result<T> {
  const Failure(this.failure, [this.stackTrace]);

  final AppFailure failure;
  final StackTrace? stackTrace;
}

/// Extension with convenient accessors and a pattern-match [fold].
extension ResultX<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Failure(:final failure) => failure,
        Success() => null,
      };

  R fold<R>(R Function(T data) onSuccess, R Function(AppFailure) onFailure) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Failure(:final failure) => onFailure(failure),
    };
  }
}
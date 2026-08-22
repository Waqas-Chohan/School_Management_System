/// Base class for every failure that can occur in the application.
sealed class AppFailure {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Failure produced by the remote server (5xx, 4xx other than 401).
final class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Failure caused by connectivity / network problems.
final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

/// Failure caused by missing / expired authentication.
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure(super.message);
}

/// Failure that could not be mapped to a more specific type.
final class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}

/// Failure used to give the user a human readable reason.
final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}
/// Represents an authenticated user session.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.employeeName,
    required this.employeeId,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String employeeName;
  final String employeeId;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? employeeName,
    String? employeeId,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
    );
  }

  @override
  String toString() => 'AuthSession(employeeId: $employeeId, '
      'employeeName: $employeeName, isExpired: $isExpired)';
}
import 'dart:convert';

import '../../domain/entities/auth_session.dart';

/// Serializable DTO for [AuthSession].
class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresAt,
    required super.employeeName,
    required super.employeeId,
  });

  /// Parses the `data` payload of the login response:
  /// `{ "token": "<jwt>", "teacher": { "id", "name", ... } }`.
  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final teacher =
        (json['teacher'] as Map? ?? const <String, dynamic>{})
            .cast<String, dynamic>();
    final token = json['token']?.toString() ?? '';
    return AuthSessionModel(
      accessToken: token,
      // The portal does not issue a separate refresh token; reuse the JWT.
      refreshToken: token,
      expiresAt: _expiryFromJwt(token) ??
          DateTime.now().add(const Duration(days: 7)),
      employeeName: teacher['name']?.toString() ?? '',
      employeeId: teacher['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': accessToken,
      'expires_at': expiresAt.toIso8601String(),
      'teacher': {
        'id': employeeId,
        'name': employeeName,
      },
    };
  }

  factory AuthSessionModel.fromEntity(AuthSession entity) {
    return AuthSessionModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      expiresAt: entity.expiresAt,
      employeeName: entity.employeeName,
      employeeId: entity.employeeId,
    );
  }

  /// Decodes the `exp` claim out of a JWT payload (seconds since epoch).
  static DateTime? _expiryFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 3) return null;
      final payload = base64Url.decode(base64Url.normalize(parts[1]));
      final claims = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
      final exp = claims['exp'];
      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      }
    } catch (_) {
      // Non-JWT tokens (e.g. demo fallbacks) are handled by the default below.
    }
    return null;
  }
}
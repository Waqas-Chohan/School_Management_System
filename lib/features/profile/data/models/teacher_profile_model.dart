import '../../domain/entities/teacher_profile.dart';

/// Serializable DTO for [TeacherProfile].
class TeacherProfileModel extends TeacherProfile {
  const TeacherProfileModel({
    required super.id,
    required super.initials,
    required super.fullName,
    required super.role,
    required super.email,
    required super.phone,
    required super.subjects,
    required super.qualification,
    required super.gender,
    required super.dateJoined,
    required super.employmentStatus,
    required super.assignedBranch,
    super.dob,
    super.avatar,
    super.pushNotificationsEnabled,
  });

  /// Maps the `/teacher-portal/profile` payload. `role` / `branch` are derived
  /// from the portal's `subject` + `branchId` fields; `initials` comes from the
  /// teacher name. `dob`, `avatar` and `pushNotificationsEnabled` map directly.
  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    final subject = json['subject']?.toString() ?? '';
    final branchId = json['branchId']?.toString() ?? '';
    return TeacherProfileModel(
      id: json['id']?.toString() ?? '',
      initials: _initialsFor(name),
      fullName: name,
      role: subject.isEmpty ? 'Teacher' : '$subject Teacher',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      subjects: [subject].where((s) => s.isNotEmpty).toList(),
      qualification: json['qualification']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dateJoined:
          DateTime.tryParse(json['joined']?.toString() ?? '') ??
              DateTime(2022, 8, 14),
      employmentStatus: json['status']?.toString() ?? 'Active',
      assignedBranch: branchId,
      dob: DateTime.tryParse(json['dob']?.toString() ?? ''),
      avatar: json['avatar']?.toString(),
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] == true ||
          json['push_notifications_enabled']?.toString() == 'true',
    );
  }

  static String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.trim().isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'initials': initials,
      'full_name': fullName,
      'role': role,
      'email': email,
      'phone': phone,
      'subjects': subjects,
      'qualification': qualification,
      'gender': gender,
      'date_joined': dateJoined.toIso8601String(),
      'employment_status': employmentStatus,
      'assigned_branch': assignedBranch,
    };
  }

  factory TeacherProfileModel.fromEntity(TeacherProfile entity) {
    return TeacherProfileModel(
      id: entity.id,
      initials: entity.initials,
      fullName: entity.fullName,
      role: entity.role,
      email: entity.email,
      phone: entity.phone,
      subjects: entity.subjects,
      qualification: entity.qualification,
      gender: entity.gender,
      dateJoined: entity.dateJoined,
      employmentStatus: entity.employmentStatus,
      assignedBranch: entity.assignedBranch,
    );
  }
}
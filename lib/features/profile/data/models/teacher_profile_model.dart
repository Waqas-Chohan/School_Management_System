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
  });

  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    return TeacherProfileModel(
      id: json['id']?.toString() ?? '',
      initials: json['initials']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      subjects: (json['subjects'] as List? ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(),
      qualification: json['qualification']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dateJoined:
          DateTime.tryParse(json['date_joined']?.toString() ?? '') ??
              DateTime(2021, 6, 12),
      employmentStatus: json['employment_status']?.toString() ?? '',
      assignedBranch: json['assigned_branch']?.toString() ?? '',
    );
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
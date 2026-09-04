/// Fields the teacher can edit through the profile screen, matching the portal's
/// `Edit Profile` (PUT) payload: name, email, dob, phone, qualification,
/// gender, avatar.
class ProfileUpdate {
  const ProfileUpdate({
    this.name,
    this.email,
    this.dob,
    this.phone,
    this.qualification,
    this.gender,
    this.avatar,
  });

  final String? name;
  final String? email;
  final DateTime? dob;
  final String? phone;
  final String? qualification;
  final String? gender;
  final String? avatar;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (email != null) 'email': email,
    if (dob != null) 'dob': dob!.toIso8601String().substring(0, 10),
    if (phone != null) 'phone': phone,
    if (qualification != null) 'qualification': qualification,
    if (gender != null) 'gender': gender,
    if (avatar != null) 'avatar': avatar,
  };
}

/// A pure domain entity representing a teacher's profile.
class TeacherProfile {
  const TeacherProfile({
    required this.id,
    required this.initials,
    required this.fullName,
    required this.role,
    required this.email,
    required this.phone,
    required this.subjects,
    required this.qualification,
    required this.gender,
    required this.dateJoined,
    required this.employmentStatus,
    required this.assignedBranch,
    this.dob,
    this.avatar,
    this.pushNotificationsEnabled = false,
  });

  final String id;
  final String initials;
  final String fullName;
  final String role;
  final String email;
  final String phone;
  final List<String> subjects;
  final String qualification;
  final String gender;
  final DateTime dateJoined;
  final String employmentStatus;
  final String assignedBranch;

  /// Teacher's date of birth (nullable on the portal).
  final DateTime? dob;

  /// Avatar image URL / path (may be a relative `/uploads/...` path).
  final String? avatar;

  /// Whether the teacher has push notifications enabled on the server.
  final bool pushNotificationsEnabled;

  String get subjectsLabel => subjects.join(', ');

  String get dateJoinedLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = dateJoined.day.toString().padLeft(2, '0');
    return '$day ${months[dateJoined.month - 1]} ${dateJoined.year}';
  }

  TeacherProfile copyWith({
    String? phone,
    String? fullName,
    String? email,
    String? gender,
    String? qualification,
    DateTime? dob,
    String? avatar,
    bool? pushNotificationsEnabled,
  }) {
    return TeacherProfile(
      id: id,
      initials: initials,
      fullName: fullName ?? this.fullName,
      role: role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      subjects: subjects,
      qualification: qualification ?? this.qualification,
      gender: gender ?? this.gender,
      dateJoined: dateJoined,
      employmentStatus: employmentStatus,
      assignedBranch: assignedBranch,
      dob: dob ?? this.dob,
      avatar: avatar ?? this.avatar,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    );
  }

  @override
  String toString() => 'TeacherProfile(id: $id, fullName: $fullName)';
}
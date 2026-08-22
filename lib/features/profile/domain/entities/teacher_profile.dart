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

  String get subjectsLabel => subjects.join(', ');

  String get dateJoinedLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = dateJoined.day.toString().padLeft(2, '0');
    return '$day ${months[dateJoined.month - 1]} ${dateJoined.year}';
  }

  TeacherProfile copyWith({String? phone}) {
    return TeacherProfile(
      id: id,
      initials: initials,
      fullName: fullName,
      role: role,
      email: email,
      phone: phone ?? this.phone,
      subjects: subjects,
      qualification: qualification,
      gender: gender,
      dateJoined: dateJoined,
      employmentStatus: employmentStatus,
      assignedBranch: assignedBranch,
    );
  }

  @override
  String toString() => 'TeacherProfile(id: $id, fullName: $fullName)';
}
import '../../../../core/result/result.dart';
import '../../domain/entities/teacher_profile.dart';
import 'profile_data_source.dart';


class ProfileMockDataSourceImpl implements ProfileDataSource {
  ProfileMockDataSourceImpl();

  TeacherProfile _profile = TeacherProfile(
    id: 'TCH-0042',
    initials: 'AS',
    fullName: 'Ms. Ananya Sharma',
    role: 'Senior PGT Mathematics',
    email: 'sharma.ananya@stxaviers.edu',
    phone: '+91 98765 43210',
    subjects: const ['Mathematics', 'Statistics'],
    qualification: 'M.Sc. in Mathematics, B.Ed.',
    gender: 'Female',
    dateJoined: DateTime(2021, 6, 12),
    employmentStatus: 'Full-Time (Permanent)',
    assignedBranch: 'Main Campus, New Delhi',
  );

  @override
  Future<Result<TeacherProfile>> fetchProfile(String accessToken) async {
    await _mockLatency();
    return Success(_profile);
  }

  @override
  Future<Result<void>> updatePhone(String accessToken, String phone) async {
    await _mockLatency();
    _profile = _profile.copyWith(phone: phone);
    return const Success(null);
  }

  Future<void> _mockLatency() {
    return Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/features/profile/data/models/teacher_profile_model.dart';

void main() {
  group('TeacherProfileModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'TCH-0042',
        'initials': 'AS',
        'full_name': 'Ms. Ananya Sharma',
        'role': 'Senior PGT Mathematics',
        'email': 'sharma.ananya@stxaviers.edu',
        'phone': '+91 98765 43210',
        'subjects': ['Mathematics', 'Statistics'],
        'qualification': 'M.Sc. in Mathematics, B.Ed.',
        'gender': 'Female',
        'date_joined': '2021-06-12T00:00:00.000',
        'employment_status': 'Full-Time (Permanent)',
        'assigned_branch': 'Main Campus, New Delhi',
      };
      final model = TeacherProfileModel.fromJson(json);
      expect(model.id, 'TCH-0042');
      expect(model.initials, 'AS');
      expect(model.fullName, 'Ms. Ananya Sharma');
      expect(model.role, 'Senior PGT Mathematics');
      expect(model.email, 'sharma.ananya@stxaviers.edu');
      expect(model.phone, '+91 98765 43210');
      expect(model.subjects, ['Mathematics', 'Statistics']);
      expect(model.subjectsLabel, 'Mathematics, Statistics');
      expect(model.qualification, 'M.Sc. in Mathematics, B.Ed.');
      expect(model.gender, 'Female');
      expect(model.dateJoined, DateTime(2021, 6, 12));
      expect(model.dateJoinedLabel, '12 Jun 2021');
      expect(model.employmentStatus, 'Full-Time (Permanent)');
      expect(model.assignedBranch, 'Main Campus, New Delhi');
    });

    test('toJson serializes correctly', () {
      final model = TeacherProfileModel(
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
      final json = model.toJson();
      expect(json['id'], 'TCH-0042');
      expect(json['initials'], 'AS');
      expect(json['full_name'], 'Ms. Ananya Sharma');
      expect(json['phone'], '+91 98765 43210');
      expect(json['subjects'], ['Mathematics', 'Statistics']);
      expect(json['date_joined'], '2021-06-12T00:00:00.000');
    });
  });
}
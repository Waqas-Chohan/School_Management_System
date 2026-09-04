import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/exam_data_source.dart';
import '../../data/datasources/exam_remote_data_source.dart';
import '../../data/repositories/exam_repository_impl.dart';
import '../../domain/entities/exam.dart';

final examRemoteDataSourceProvider = Provider<ExamDataSource>((ref) {
  return ExamRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final examRepositoryProvider = Provider<ExamRepositoryImpl>((ref) {
  return ExamRepositoryImpl(ref.watch(examRemoteDataSourceProvider));
});

/// Provider exposing exams + datesheets with a combined loading indicator.
final examsOverviewProvider = FutureProvider<ExamOverview>(
  (ref) async {
    final token = ref.read(authSessionProvider)?.accessToken ?? '';
    final result = await ref.read(examRepositoryProvider).fetchExams(token);
    return result.fold((data) => data, (failure) => throw failure);
  },
);

final dateSheetsProvider = FutureProvider<List<DateSheet>>(
  (ref) async {
    final token = ref.read(authSessionProvider)?.accessToken ?? '';
    final result = await ref
        .read(examRepositoryProvider)
        .fetchDateSheets(token, classId: null);
    return result.fold((data) => data, (failure) => throw failure);
  },
);
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/attendance_data_source.dart';
import '../../data/datasources/attendance_mock_data_source.dart';
import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/get_attendance_summary_usecase.dart';

// ── Data layer providers ─────────────────────────────

final attendanceMockDataSourceProvider = Provider<AttendanceDataSource>((ref) {
  return AttendanceMockDataSourceImpl();
});

final attendanceRemoteDataSourceProvider = Provider<AttendanceDataSource>((ref) {
  return AttendanceRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

// Swap to `ref.watch(attendanceRemoteDataSourceProvider)` when the API is ready.
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(attendanceMockDataSourceProvider));
});

// ── Use case providers ───────────────────────────────

final getAttendanceSummaryUseCaseProvider =
    Provider<GetAttendanceSummaryUseCase>((ref) {
  return GetAttendanceSummaryUseCase(ref.watch(attendanceRepositoryProvider));
});

String _readAccessToken(Ref ref) {
  return ref.read(authSessionProvider)?.accessToken ?? '';
}

// ── State ────────────────────────────────────────────

final attendanceSummaryProvider =
    FutureProvider.autoDispose<AttendanceSummary>((ref) async {
  final accessToken = _readAccessToken(ref);
  final result = await ref.read(getAttendanceSummaryUseCaseProvider)(
    GetAttendanceSummaryParams(accessToken: accessToken),
  );
  return result.fold((summary) => summary, (failure) => throw failure);
});
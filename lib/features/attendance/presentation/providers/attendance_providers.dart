import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/attendance_data_source.dart';
import '../../data/datasources/attendance_mock_data_source.dart';
import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/datasources/check_in_out_data_source.dart';
import '../../data/datasources/check_in_out_mock_data_source.dart';
import '../../data/datasources/check_in_out_remote_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/get_attendance_summary_usecase.dart';

// ── Data layer providers ─────────────────────────────

final attendanceMockDataSourceProvider = Provider<AttendanceDataSource>((ref) {
  return AttendanceMockDataSourceImpl();
});

final attendanceRemoteDataSourceProvider = Provider<AttendanceDataSource>((
  ref,
) {
  return AttendanceRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final checkInOutMockDataSourceProvider = Provider<CheckInOutDataSource>((ref) {
  return CheckInOutMockDataSourceImpl();
});

final checkInOutRemoteDataSourceProvider = Provider<CheckInOutDataSource>((ref) {
  return CheckInOutRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

// Remote-first provider: the repository falls back to the mock source only
// when the live API is unreachable.
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    ref.watch(attendanceMockDataSourceProvider),
    ref.watch(attendanceRemoteDataSourceProvider),
    ref.watch(checkInOutMockDataSourceProvider),
    ref.watch(checkInOutRemoteDataSourceProvider),
  );
});

// ── Use case providers ───────────────────────────────

final getAttendanceSummaryUseCaseProvider =
    Provider<GetAttendanceSummaryUseCase>((ref) {
      return GetAttendanceSummaryUseCase(
        ref.watch(attendanceRepositoryProvider),
      );
    });

String _readAccessToken(Ref ref) {
  return ref.read(authSessionProvider)?.accessToken ?? '';
}

// ── State ────────────────────────────────────────────

final attendanceSummaryProvider = FutureProvider.autoDispose<AttendanceSummary>(
  (ref) async {
    final accessToken = _readAccessToken(ref);
    final result = await ref.read(getAttendanceSummaryUseCaseProvider)(
      GetAttendanceSummaryParams(accessToken: accessToken),
    );
    return result.fold((summary) => summary, (failure) => throw failure);
  },
);

// ── Check-In / Check-Out controller ──────────────────

final checkInOutControllerProvider =
    NotifierProvider<CheckInOutController, AsyncValue<CheckInOutResult?>>(
      CheckInOutController.new,
    );

class CheckInOutController extends Notifier<AsyncValue<CheckInOutResult?>> {
  @override
  AsyncValue<CheckInOutResult?> build() => const AsyncData(null);

  bool get isSubmitting => state is AsyncLoading;

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
          ? (state as AsyncError).error as AppFailure
          : const UnknownFailure('Update failed.')
      : null;

  Future<CheckInOutResult?> checkIn() async {
    return _submit(
      (token) => ref.read(attendanceRepositoryProvider).checkIn(accessToken: token),
    );
  }

  Future<CheckInOutResult?> checkOut() async {
    return _submit(
      (token) => ref.read(attendanceRepositoryProvider).checkOut(accessToken: token),
    );
  }

  Future<CheckInOutResult?> _submit(
    Future<Result<CheckInOutResult>> Function(String token) action,
  ) async {
    final accessToken = _readAccessToken(ref);
    state = const AsyncLoading();
    final result = await action(accessToken);
    state = result.fold(
      (data) {
        // Invalidate the summary so the attendance page refreshes with today's
        // check-in / check-out row.
        ref.invalidate(attendanceSummaryProvider);
        return AsyncData(data);
      },
      (failure) => AsyncError(failure, StackTrace.current),
    );
    return state is AsyncData ? state.value : null;
  }
}

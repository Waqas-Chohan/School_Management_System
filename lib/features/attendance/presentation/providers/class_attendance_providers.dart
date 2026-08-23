import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/class_attendance_data_source.dart';
import '../../data/datasources/class_attendance_mock_data_source.dart';
import '../../data/repositories/class_attendance_repository_impl.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/repositories/class_attendance_repository.dart';
import '../../domain/usecases/get_classes_usecase.dart';
import '../../domain/usecases/get_saved_attendance_usecase.dart';
import '../../domain/usecases/submit_class_attendance_usecase.dart';

// ── Data layer providers ─────────────────────────────

final classAttendanceMockDataSourceProvider =
    Provider<ClassAttendanceDataSource>((ref) {
      return ClassAttendanceMockDataSourceImpl();
    });

final classAttendanceRemoteDataSourceProvider =
    Provider<ClassAttendanceDataSource>((ref) {
      throw UnimplementedError('Class attendance remote API is not ready yet.');
    });

// Swap to the remote source when the API is ready.
final classAttendanceRepositoryProvider = Provider<ClassAttendanceRepository>((
  ref,
) {
  return ClassAttendanceRepositoryImpl(
    ref.watch(classAttendanceMockDataSourceProvider),
  );
});

// ── Use case providers ───────────────────────────────

final getClassesUseCaseProvider = Provider<GetClassesUseCase>((ref) {
  return GetClassesUseCase(ref.watch(classAttendanceRepositoryProvider));
});

final submitClassAttendanceUseCaseProvider =
    Provider<SubmitClassAttendanceUseCase>((ref) {
      return SubmitClassAttendanceUseCase(
        ref.watch(classAttendanceRepositoryProvider),
      );
    });

final getSavedAttendanceUseCaseProvider = Provider<GetSavedAttendanceUseCase>(
  (ref) =>
      GetSavedAttendanceUseCase(ref.watch(classAttendanceRepositoryProvider)),
);

String _readAccessToken(Ref ref) {
  return ref.read(authSessionProvider)?.accessToken ?? '';
}

// ── State ────────────────────────────────────────────

/// The teacher's classes on the "My Classes" screen.
final teacherClassesProvider = FutureProvider.autoDispose<List<TeacherClass>>((
  ref,
) async {
  final accessToken = _readAccessToken(ref);
  final result = await ref.read(getClassesUseCaseProvider)(accessToken);
  return result.fold((classes) => classes, (failure) => throw failure);
});

/// The roster for a single class on the Mark Attendance screen.
final classAttendanceProvider = FutureProvider.autoDispose
    .family<ClassAttendance, String>((ref, classId) async {
      final accessToken = _readAccessToken(ref);
      final repository = ref.read(classAttendanceRepositoryProvider);
      final result = await repository.getClassAttendance(accessToken, classId);
      return result.fold((data) => data, (failure) => throw failure);
    });

/// The already-saved attendance sheet for a class (Attendance Details screen).
final savedClassAttendanceProvider = FutureProvider.autoDispose
    .family<ClassAttendance, String>((ref, classId) async {
      final accessToken = _readAccessToken(ref);
      final result = await ref.read(getSavedAttendanceUseCaseProvider)(
        accessToken,
        classId,
      );
      return result.fold((data) => data, (failure) => throw failure);
    });

// ── Submit controller ────────────────────────────────

final submitClassAttendanceControllerProvider =
    NotifierProvider<SubmitClassAttendanceController, AsyncValue<void>>(
      SubmitClassAttendanceController.new,
    );

class SubmitClassAttendanceController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
            ? (state as AsyncError).error as AppFailure
            : const UnknownFailure('Unable to submit attendance.')
      : null;

  Future<bool> submit({
    required String classId,
    required Map<String, StudentAttendanceStatus> statusByStudent,
  }) async {
    final accessToken = ref.read(authSessionProvider)?.accessToken ?? '';
    state = const AsyncLoading();
    final result = await ref.read(submitClassAttendanceUseCaseProvider)(
      accessToken: accessToken,
      classId: classId,
      statusByStudent: statusByStudent,
    );
    state = result.fold((_) {
      ref.invalidate(teacherClassesProvider);
      return const AsyncData(null);
    }, (failure) => AsyncError(failure, StackTrace.current));
    return state is AsyncData;
  }
}

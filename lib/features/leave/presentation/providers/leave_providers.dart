import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/leave_data_source.dart';
import '../../data/datasources/leave_mock_data_source.dart';
import '../../data/datasources/leave_remote_data_source.dart';
import '../../data/repositories/leave_repository_impl.dart';
import '../../domain/entities/leave.dart';
import '../../domain/repositories/leave_repository.dart';
import '../../domain/usecases/create_leave_usecase.dart';
import '../../domain/usecases/get_leaves_usecase.dart';

// ── Data layer providers ─────────────────────────────

final leaveMockDataSourceProvider = Provider<LeaveDataSource>((ref) {
  return LeaveMockDataSourceImpl();
});

final leaveRemoteDataSourceProvider = Provider<LeaveDataSource>((ref) {
  return LeaveRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

// Remote-first provider: the repository falls back to the mock source only
// when the live API is unreachable.
final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepositoryImpl(
    ref.watch(leaveMockDataSourceProvider),
    ref.watch(leaveRemoteDataSourceProvider),
  );
});

// ── Use case providers ───────────────────────────────

final getLeavesUseCaseProvider = Provider<GetLeavesUseCase>((ref) {
  return GetLeavesUseCase(ref.watch(leaveRepositoryProvider));
});

final createLeaveUseCaseProvider = Provider<CreateLeaveUseCase>((ref) {
  return CreateLeaveUseCase(ref.watch(leaveRepositoryProvider));
});

// ── State ────────────────────────────────────────────

/// Active status filter on the Leaves list (null = All).
final leaveFilterProvider =
    NotifierProvider<LeaveFilterNotifier, LeaveStatus?>(
      LeaveFilterNotifier.new,
    );

class LeaveFilterNotifier extends Notifier<LeaveStatus?> {
  @override
  LeaveStatus? build() => null;

  void set(LeaveStatus? status) => state = status;
}

final leavesProvider = FutureProvider.autoDispose<List<LeaveRequest>>((ref) async {
  final accessToken = ref.read(authSessionProvider)?.accessToken ?? '';
  final filter = ref.watch(leaveFilterProvider);
  final result = await ref.read(getLeavesUseCaseProvider)(
    GetLeavesParams(accessToken: accessToken, filter: filter),
  );
  return result.fold((leaves) => leaves, (failure) => throw failure);
});

// ── Create controller ────────────────────────────────

final createLeaveControllerProvider =
    NotifierProvider<CreateLeaveController, AsyncValue<void>>(
      CreateLeaveController.new,
    );

class CreateLeaveController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
          ? (state as AsyncError).error as AppFailure
          : const UnknownFailure('Unable to submit the leave request.')
      : null;

  Future<bool> submit({
    required LeaveType type,
    required LeaveMode mode,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    List<String> attachments = const [],
  }) async {
    final accessToken = ref.read(authSessionProvider)?.accessToken ?? '';
    state = const AsyncLoading();
    final result = await ref.read(createLeaveUseCaseProvider)(
      CreateLeaveParams(
        accessToken: accessToken,
        input: CreateLeaveInput(
          type: type,
          mode: mode,
          startDate: startDate,
          endDate: endDate,
          reason: reason,
          attachments: attachments,
        ),
      ),
    );
    state = result.fold((_) {
      ref.invalidate(leavesProvider);
      return const AsyncData(null);
    }, (failure) => AsyncError(failure, StackTrace.current));
    return state is AsyncData;
  }
}
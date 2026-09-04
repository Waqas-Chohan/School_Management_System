import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/dashboard_data_source.dart';
import '../../data/datasources/dashboard_mock_data_source.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';

final dashboardMockDataSourceProvider = Provider<DashboardDataSource>((ref) {
  return DashboardMockDataSourceImpl();
});

final dashboardRemoteDataSourceProvider = Provider<DashboardDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

// Remote-first provider: the repository falls back to the mock source only
// when the live API is unreachable.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    ref.watch(dashboardMockDataSourceProvider),
    ref.watch(dashboardRemoteDataSourceProvider),
  );
});

final getDashboardSummaryUseCaseProvider =
    Provider<GetDashboardSummaryUseCase>((ref) {
  return GetDashboardSummaryUseCase(ref.watch(dashboardRepositoryProvider));
});

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>(
  (ref) async {
    final accessToken = ref.read(authSessionProvider)?.accessToken ?? '';
    final result = await ref.read(getDashboardSummaryUseCaseProvider)(
      GetDashboardSummaryParams(accessToken: accessToken),
    );
    return result.fold((summary) => summary, (failure) => throw failure);
  },
);
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/feature_mock_data_source.dart';
import '../../data/datasources/feature_remote_data_source.dart';
import '../../data/repositories/feature_repository_impl.dart';
import '../../domain/entities/feature.dart';
import '../../domain/repositories/feature_repository.dart';
import '../../domain/usecases/create_feature_usecase.dart';
import '../../domain/usecases/get_features_usecase.dart';
import '../../domain/usecases/update_feature_usecase.dart';

final featureMockDataSourceProvider = Provider<FeatureMockDataSource>((ref) {
  return FeatureMockDataSourceImpl();
});

final featureRemoteDataSourceProvider = Provider<FeatureRemoteDataSource>((ref) {
  return FeatureRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

// Swap to `featureMockDataSourceProvider` here to use the mock during dev.
final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  return FeatureRepositoryImpl(ref.watch(featureRemoteDataSourceProvider));
});

final getFeaturesUseCaseProvider = Provider<GetFeaturesUseCase>((ref) {
  return GetFeaturesUseCase(ref.watch(featureRepositoryProvider));
});

final createFeatureUseCaseProvider = Provider<CreateFeatureUseCase>((ref) {
  return CreateFeatureUseCase(ref.watch(featureRepositoryProvider));
});

final updateFeatureUseCaseProvider = Provider<UpdateFeatureUseCase>((ref) {
  return UpdateFeatureUseCase(ref.watch(featureRepositoryProvider));
});

String _readAccessToken(Ref ref) {
  return ref.read(authSessionProvider)?.accessToken ?? '';
}

final featuresProvider = FutureProvider.autoDispose<List<Feature>>((ref) async {
  final accessToken = _readAccessToken(ref);
  final result = await ref
      .read(getFeaturesUseCaseProvider)(GetFeaturesParams(accessToken: accessToken));
  return result.fold((features) => features, (failure) => throw failure);
});

final createFeatureControllerProvider =
    NotifierProvider<CreateFeatureController, AsyncValue<void>>(
      CreateFeatureController.new,
    );

class CreateFeatureController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createFeature({required String name}) async {
    final accessToken = _readAccessToken(ref);
    if (accessToken.isEmpty) {
      state = AsyncError(
        const UnauthorizedFailure('Please login to create a feature.'),
        StackTrace.current,
      );
      return false;
    }
    state = const AsyncLoading();
    final result = await ref.read(createFeatureUseCaseProvider)(
      CreateFeatureParams(accessToken: accessToken, name: name),
    );
    state = result.fold((_) {
      ref.invalidate(featuresProvider);
      return const AsyncData<void>(null);
    }, (failure) => AsyncError(failure, StackTrace.current));
    return state is AsyncData;
  }
}

final updateFeatureControllerProvider =
    NotifierProvider<UpdateFeatureController, AsyncValue<void>>(
      UpdateFeatureController.new,
    );

class UpdateFeatureController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> updateFeature({required Feature feature}) async {
    final accessToken = _readAccessToken(ref);
    state = const AsyncLoading();
    final result = await ref.read(updateFeatureUseCaseProvider)(
      UpdateFeatureParams(accessToken: accessToken, feature: feature),
    );
    state = result.fold((_) {
      ref.invalidate(featuresProvider);
      return const AsyncData(null);
    }, (failure) => AsyncError(failure, StackTrace.current));
    return state is AsyncData;
  }
}
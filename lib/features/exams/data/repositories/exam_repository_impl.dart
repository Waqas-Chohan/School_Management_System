import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/exam.dart';
import '../datasources/exam_data_source.dart';

/// Repository for exams + datesheet backed by the live portal API. No mock
/// fallback is needed here — if the network is down or the API is unreachable
/// the UI shows the empty state directly from the failure.
class ExamRepositoryImpl {
  const ExamRepositoryImpl(this._remoteDataSource);

  final ExamDataSource _remoteDataSource;

  Future<Result<ExamOverview>> fetchExams(String accessToken) {
    if (accessToken.isEmpty) {
      return Future.value(
        Failure(UnauthorizedFailure('Please login to view exams.')),
      );
    }
    return _remoteDataSource.fetchExams(accessToken);
  }

  Future<Result<List<DateSheet>>> fetchDateSheets(
    String accessToken, {
    String? classId,
  }) {
    if (accessToken.isEmpty) {
      return Future.value(
        Failure(UnauthorizedFailure('Please login to view datesheets.')),
      );
    }
    return _remoteDataSource.fetchDateSheets(accessToken, classId: classId);
  }
}
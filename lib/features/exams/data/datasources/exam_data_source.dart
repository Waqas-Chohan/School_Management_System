import '../../../../core/result/result.dart';
import '../../domain/entities/exam.dart';

/// Contract for the Exams + Datesheet data layer.
abstract class ExamDataSource {
  /// Gets the exams overview (active / upcoming / completed + datesheets).
  Future<Result<ExamOverview>> fetchExams(String accessToken);

  /// Gets the exam datesheets, optionally filtered by class.
  Future<Result<List<DateSheet>>> fetchDateSheets(
    String accessToken, {
    String? classId,
  });
}
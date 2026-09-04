import '../../../../core/result/result.dart';
import '../../domain/entities/attendance.dart';
import 'check_in_out_data_source.dart';

/// Mock check-in / check-out used as an offline fallback when the live API is
/// unreachable. Returns a locally-computed timestamp the same shape the portal
/// returns, so the UI behaves identically.
class CheckInOutMockDataSourceImpl implements CheckInOutDataSource {
  CheckInOutMockDataSourceImpl();

  String _nowHHMM() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Future<Result<CheckInOutResult>> checkIn(String accessToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Success(
      CheckInOutResult(
        message: 'Checked in successfully at ${_nowHHMM()}',
        status: 'Present',
        checkIn: _nowHHMM(),
        checkOut: null,
      ),
    );
  }

  @override
  Future<Result<CheckInOutResult>> checkOut(String accessToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Success(
      CheckInOutResult(
        message: 'Checked out successfully at ${_nowHHMM()}',
        status: 'Present',
        checkIn: null,
        checkOut: _nowHHMM(),
      ),
    );
  }
}
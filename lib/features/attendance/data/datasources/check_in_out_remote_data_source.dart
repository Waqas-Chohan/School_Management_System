import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/portal_time.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/attendance.dart';
import 'check_in_out_data_source.dart';

/// Remote check-in / check-out data source backed by the SMS portal:
/// - `POST /teacher-portal/attendance/check-in`
/// - `POST /teacher-portal/attendance/check-out`
///
/// Both take an empty `{}` body, require the teacher JWT, and return the
/// saved StaffAttendance row with `checkIn` / `checkOut` timestamps.
class CheckInOutRemoteDataSourceImpl implements CheckInOutDataSource {
  CheckInOutRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<Result<CheckInOutResult>> checkIn(String accessToken) {
    return _post(ApiEndpoints.checkIn, accessToken);
  }

  @override
  Future<Result<CheckInOutResult>> checkOut(String accessToken) {
    return _post(ApiEndpoints.checkOut, accessToken);
  }

  Future<Result<CheckInOutResult>> _post(String path, String accessToken) {
    return guardApi(() async {
      final response = await dio.post<Map<String, dynamic>>(
        path,
        data: <String, dynamic>{},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      // `message` lives at the envelope root; the times live inside `data`.
      final body = response.data ?? const <String, dynamic>{};
      final dataMap = envelopeMap(body);
      // The portal stores timestamps in UTC and returns them as bare "HH:MM"
      // strings plus the server date; convert them to the device's local time
      // so the card and the success dialog show the real local clock time.
      // (Bare 24h values that can't be converted fall back to the raw text.)
      final recordDate = dataMap['date']?.toString() ?? '';
      String? clock(String? raw) {
        if (raw == null) return null;
        final local = PortalTime.toLocal(date: recordDate, time: raw);
        if (local != null) return DateFormat('hh:mm a').format(local);
        final iso = DateTime.tryParse(raw);
        if (iso != null) {
          final converted = iso.isUtc ? iso.toLocal() : iso;
          return DateFormat('hh:mm a').format(converted);
        }
        return raw;
      }

      return CheckInOutResult(
        message:
            body['message']?.toString() ??
            dataMap['message']?.toString() ??
            'Done.',
        status: dataMap['status']?.toString() ?? '',
        checkIn: clock(dataMap['checkIn']?.toString()),
        checkOut: clock(dataMap['checkOut']?.toString()),
      );
    });
  }
}

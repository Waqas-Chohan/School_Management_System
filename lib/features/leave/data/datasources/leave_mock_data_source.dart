import '../../../../core/result/result.dart';
import '../../domain/entities/leave.dart';
import '../models/leave_model.dart';
import 'leave_data_source.dart';

/// Mock leave data source populated with the exact rows from the Figma
/// "Leave" design (section 76:6156).
class LeaveMockDataSourceImpl implements LeaveDataSource {
  LeaveMockDataSourceImpl();

  final List<LeaveModel> _leaves = [
    LeaveModel(
      id: '1',
      type: LeaveType.family,
      mode: LeaveMode.multiple,
      startDate: DateTime(2026, 7, 5),
      endDate: DateTime(2026, 7, 8),
      reason: 'Attending a family function, need a day off.',
      status: LeaveStatus.pending,
    ),
    LeaveModel(
      id: '2',
      type: LeaveType.sick,
      mode: LeaveMode.multiple,
      startDate: DateTime(2026, 6, 12),
      endDate: DateTime(2026, 6, 13),
      reason: 'Viral fever, doctor advised complete rest.',
      status: LeaveStatus.approved,
    ),
    LeaveModel(
      id: '3',
      type: LeaveType.casual,
      mode: LeaveMode.single,
      startDate: DateTime(2026, 5, 28),
      endDate: DateTime(2026, 5, 28),
      reason: 'Personal family emergency, need a day off.',
      status: LeaveStatus.approved,
    ),
    LeaveModel(
      id: '4',
      type: LeaveType.annual,
      mode: LeaveMode.multiple,
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 3, 6),
      reason: 'Planned annual vacation with family.',
      status: LeaveStatus.pending,
    ),
  ];

  @override
  Future<Result<List<LeaveRequest>>> fetchLeaves(
    String accessToken, {
    LeaveStatus? filter,
  }) async {
    await _mockLatency();
    final list = filter == null
        ? _leaves
        : _leaves.where((e) => e.status == filter).toList();
    return Success(List<LeaveRequest>.unmodifiable(list));
  }

  @override
  Future<Result<void>> createLeave(String accessToken, LeaveDraft draft) async {
    await _mockLatency();
    _leaves.insert(
      0,
      LeaveModel(
        id: '${_leaves.length + 1}',
        type: draft.type,
        mode: draft.mode,
        startDate: draft.startDate,
        endDate: draft.endDate,
        reason: draft.reason,
        status: LeaveStatus.pending,
        attachments: draft.attachments,
      ),
    );
    return const Success(null);
  }

  Future<void> _mockLatency() {
    return Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
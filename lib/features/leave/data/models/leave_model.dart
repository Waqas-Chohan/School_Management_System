import '../../domain/entities/leave.dart';

/// Serializable DTO for [LeaveRequest].
class LeaveModel extends LeaveRequest {
  const LeaveModel({
    required super.id,
    required super.type,
    required super.mode,
    required super.startDate,
    required super.endDate,
    required super.reason,
    super.status,
    super.attachments,
  });

  /// Parses a leave record from the portal. Accepts the documented keys
  /// (`type`, `from`, `to`, `days`, `reason`, `status`, `appliedOn`) plus the
  /// older `start_date` / `end_date` aliases used by the local mock.
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    final start = DateTime.tryParse(
          json['from']?.toString() ?? json['start_date']?.toString() ?? '',
        ) ??
        DateTime.now();
    final end = DateTime.tryParse(
          json['to']?.toString() ?? json['end_date']?.toString() ?? '',
        ) ??
        DateTime.now();
    return LeaveModel(
      id: json['id']?.toString() ?? '',
      type: _typeFromJson(json['type']?.toString()),
      mode: start == end ? LeaveMode.single : LeaveMode.multiple,
      startDate: start,
      endDate: end,
      reason: json['reason']?.toString() ?? '',
      status: _statusFromJson(json['status']?.toString()),
      attachments: (json['attachments'] as List? ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'mode': mode.name == 'multiple' ? 'multiple' : 'single',
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
      'status': status.name,
      'attachments': attachments,
    };
  }

  factory LeaveModel.fromEntity(LeaveRequest entity) {
    return LeaveModel(
      id: entity.id,
      type: entity.type,
      mode: entity.mode,
      startDate: entity.startDate,
      endDate: entity.endDate,
      reason: entity.reason,
      status: entity.status,
      attachments: entity.attachments,
    );
  }
}

LeaveType _typeFromJson(String? value) {
  return switch (value?.toLowerCase()) {
    'casual' => LeaveType.casual,
    'annual' => LeaveType.annual,
    'family' => LeaveType.family,
    'other' => LeaveType.other,
    'sick' => LeaveType.sick,
    _ => LeaveType.sick,
  };
}

LeaveStatus _statusFromJson(String? value) {
  return switch (value?.toLowerCase()) {
    'approved' => LeaveStatus.approved,
    'rejected' => LeaveStatus.rejected,
    'cancelled' => LeaveStatus.cancelled,
    'pending' => LeaveStatus.pending,
    _ => LeaveStatus.pending,
  };
}
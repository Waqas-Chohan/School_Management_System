/// Pure domain entity for a generic feature row.
class Feature {
  const Feature({
    required this.id,
    required this.name,
    this.status = 'pending',
  });

  final String id;
  final String name;
  final String status;

  String get statusLabel => switch (status) {
        'approved' => 'Approved',
        'rejected' => 'Rejected',
        _ => 'Pending',
      };

  @override
  String toString() => 'Feature(id: $id, name: $name, status: $status)';
}
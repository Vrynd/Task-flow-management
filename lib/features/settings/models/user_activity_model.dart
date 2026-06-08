/// Model data untuk log aktivitas pengguna.
class UserActivityModel {
  final String id;
  final String actionType;
  final String description;
  final DateTime createdAt;

  const UserActivityModel({
    required this.id,
    required this.actionType,
    required this.description,
    required this.createdAt,
  });

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      id: json['id'] as String? ?? '',
      actionType: json['action_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_type': actionType,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  String toString() => 'UserActivityModel(action: $actionType, desc: $description)';
}

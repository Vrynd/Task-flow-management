import 'category_model.dart';
import 'task_priority.dart';
import 'task_status.dart';
export 'category_model.dart';
export 'task_priority.dart';
export 'task_status.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? deadline;
  final CategoryModel? category;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.deadline,
    this.category,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priority: TaskPriority.fromString(json['priority'] as String? ?? 'LOW'),
      status: TaskStatus.fromString(json['status'] as String? ?? 'TODO'),
      deadline: _parseDate(json['deadline']),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  // Serialization
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'priority': priority.toApiString(),
      'status': status.toApiString(),
    };
    if (description != null) map['description'] = description;
    if (deadline != null) {
      map['deadline'] =
          '${deadline!.year.toString().padLeft(4, '0')}-'
          '${deadline!.month.toString().padLeft(2, '0')}-'
          '${deadline!.day.toString().padLeft(2, '0')}';
    }
    if (category != null) map['category'] = category!.toJson();
    return map;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  bool get isOverdue {
    if (deadline == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return deadline!.isBefore(today) && status != TaskStatus.done;
  }

  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dl = DateTime(deadline!.year, deadline!.month, deadline!.day);
    return dl == today;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? deadline,
    CategoryModel? category,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
    );
  }

  @override
  String toString() => 'TaskModel(id: $id, title: $title, priority: $priority)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

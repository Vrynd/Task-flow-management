import 'package:flutter/material.dart';

/// Enum prioritas tugas sesuai nilai dari API.
enum TaskPriority {
  high,
  medium,
  low;

  /// Parse string dari API → enum
  static TaskPriority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'HIGH':
        return TaskPriority.high;
      case 'MEDIUM':
        return TaskPriority.medium;
      case 'LOW':
      default:
        return TaskPriority.low;
    }
  }

  /// Konversi ke string untuk API request
  String toApiString() {
    switch (this) {
      case TaskPriority.high:
        return 'HIGH';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.low:
        return 'LOW';
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'Tinggi';
      case TaskPriority.medium:
        return 'Sedang';
      case TaskPriority.low:
        return 'Rendah';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.high:
        return const Color(0xFFF43F5E);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.low:
        return const Color(0xFF10B981);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TaskPriority.high:
        return const Color(0xFFFFF1F2);
      case TaskPriority.medium:
        return const Color(0xFFFFFBEB);
      case TaskPriority.low:
        return const Color(0xFFECFDF5);
    }
  }
}

/// Enum status tugas.
enum TaskStatus {
  todo,
  inProgress,
  done;

  static TaskStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'DONE':
        return TaskStatus.done;
      case 'TODO':
      default:
        return TaskStatus.todo;
    }
  }

  String toApiString() {
    switch (this) {
      case TaskStatus.todo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Belum Mulai';
      case TaskStatus.inProgress:
        return 'Sedang Dikerjakan';
      case TaskStatus.done:
        return 'Selesai';
    }
  }
}

// ─── Category Model ───────────────────────────────────────────────────────────

/// Model untuk kategori tugas.
class CategoryModel {
  final String? id;
  final String name;
  final String color;

  const CategoryModel({
    this.id,
    required this.name,
    required this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '#6366F1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
    };
  }

  /// Parse hex color string menjadi Flutter Color.
  Color toFlutterColor() {
    try {
      final hex = color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }

  @override
  String toString() => 'CategoryModel(name: $name, color: $color)';
}

// ─── Task Model ───────────────────────────────────────────────────────────────

/// Model data untuk entitas Task.
///
/// Plain Dart class, tidak boleh import widget/screen apapun
/// kecuali package:flutter/material.dart untuk Color.
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

  // ─── Factory Constructor ─────────────────────────────────────────────────

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

  // ─── Serialization ────────────────────────────────────────────────────────

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

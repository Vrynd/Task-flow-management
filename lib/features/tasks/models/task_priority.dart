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

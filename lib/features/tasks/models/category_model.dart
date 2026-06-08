import 'package:flutter/material.dart';

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

import 'package:task_management/core/services/api_service.dart';
import 'package:task_management/features/tasks/models/task_model.dart';

class TaskService {
  final ApiService _api;
  TaskService({ApiService? apiService}) : _api = apiService ?? ApiService();

  static const String _tasksEndpoint = '/api/tasks';

  // Membuat tugas baru
  Future<TaskModel> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    DateTime? deadline,
    CategoryModel? category,
    String? authToken,
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
      'priority': priority.toApiString(),
    };

    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }

    if (deadline != null) {
      body['deadline'] =
          '${deadline.year.toString().padLeft(4, '0')}-'
          '${deadline.month.toString().padLeft(2, '0')}-'
          '${deadline.day.toString().padLeft(2, '0')}';
    }

    if (category != null) {
      body['category'] = category.toJson();
    }

    final response = await _api.post(
      _tasksEndpoint,
      body: body,
      authToken: authToken,
    );

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException(message: 'Format respons tidak valid');
    }

    return TaskModel.fromJson(data);
  }

  // Mengambil semua tugas
  Future<List<TaskModel>> getTasks({String? authToken}) async {
    final response = await _api.get(_tasksEndpoint, authToken: authToken);

    final rawList = response['data'];
    if (rawList == null) return [];

    if (rawList is List) {
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList();
    }

    return [];
  }

  // Memperbarui tugas yang sudah ada
  Future<TaskModel> updateTask({
    required String id,
    required String title,
    String? description,
    required TaskPriority priority,
    DateTime? deadline,
    CategoryModel? category,
    TaskStatus? status,
    String? authToken,
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
      'priority': priority.toApiString(),
    };

    if (description != null) {
      body['description'] = description.trim();
    }

    if (deadline != null) {
      body['deadline'] =
          '${deadline.year.toString().padLeft(4, '0')}-'
          '${deadline.month.toString().padLeft(2, '0')}-'
          '${deadline.day.toString().padLeft(2, '0')}';
    }

    if (category != null) {
      body['category'] = category.toJson();
    }

    if (status != null) {
      body['status'] = status.toApiString();
    }

    final response = await _api.put(
      '$_tasksEndpoint/$id',
      body: body,
      authToken: authToken,
    );

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException(message: 'Format respons tidak valid');
    }

    return TaskModel.fromJson(data);
  }

  // Memperbarui hanya status tugas
  Future<TaskModel> updateTaskStatus({
    required String id,
    required TaskStatus status,
    String? authToken,
  }) async {
    final body = <String, dynamic>{'status': status.toApiString()};

    final response = await _api.put(
      '$_tasksEndpoint/$id/status',
      body: body,
      authToken: authToken,
    );

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException(message: 'Format respons tidak valid');
    }

    return TaskModel.fromJson(data);
  }

  // Menghapus tugas
  Future<bool> deleteTask({required String id, String? authToken}) async {
    final response = await _api.delete(
      '$_tasksEndpoint/$id',
      authToken: authToken,
    );

    return response['success'] as bool? ?? false;
  }
}

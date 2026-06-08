import '../../../../core/services/api_service.dart';
import '../models/task_model.dart';

/// [TaskService] menangani semua API call yang berkaitan dengan tasks.
///
/// Bergantung pada [ApiService] sebagai HTTP client terpusat.
/// Tidak boleh import widget atau screen apapun.
class TaskService {
  final ApiService _api;

  TaskService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  static const String _tasksEndpoint = '/api/tasks';

  // ─── Create Task ──────────────────────────────────────────────────────────

  /// Membuat tugas baru ke server.
  ///
  /// Melempar [ApiException] jika terjadi error.
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

    // Response: { success, message, data: { ...task } }
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException(message: 'Format respons tidak valid');
    }

    return TaskModel.fromJson(data);
  }

  // ─── Get All Tasks ────────────────────────────────────────────────────────

  /// Mengambil semua tugas dari server.
  ///
  /// Melempar [ApiException] jika terjadi error.
  Future<List<TaskModel>> getTasks({String? authToken}) async {
    final response = await _api.get(
      _tasksEndpoint,
      authToken: authToken,
    );

    // Response: { success, message, data: [ ...tasks ] }
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

  // ─── Update Task ──────────────────────────────────────────────────────────

  /// Memperbarui tugas yang sudah ada di server.
  ///
  /// Melempar [ApiException] jika terjadi error.
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

    // Response: { success, message, data: { ...task } }
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException(message: 'Format respons tidak valid');
    }

    return TaskModel.fromJson(data);
  }

  // ─── Update Task Status ───────────────────────────────────────────────────

  /// Memperbarui hanya status tugas di server.
  ///
  /// Melempar [ApiException] jika terjadi error.
  Future<TaskModel> updateTaskStatus({
    required String id,
    required TaskStatus status,
    String? authToken,
  }) async {
    final body = <String, dynamic>{
      'status': status.toApiString(),
    };

    final response = await _api.put(
      '$_tasksEndpoint/$id/status',
      body: body,
      authToken: authToken,
    );

    // Response: { success, message, data: { ...task } }
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException(message: 'Format respons tidak valid');
    }

    return TaskModel.fromJson(data);
  }

  // ─── Delete Task ──────────────────────────────────────────────────────────

  /// Menghapus tugas dari server.
  ///
  /// Melempar [ApiException] jika terjadi error.
  Future<bool> deleteTask({
    required String id,
    String? authToken,
  }) async {
    final response = await _api.delete(
      '$_tasksEndpoint/$id',
      authToken: authToken,
    );

    return response['success'] as bool? ?? false;
  }
}

import 'package:flutter/foundation.dart';
import 'package:task_management/core/services/api_service.dart';
import 'package:task_management/features/tasks/models/task_model.dart';
import 'package:task_management/features/tasks/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  TaskProvider({TaskService? taskService})
    : _taskService = taskService ?? TaskService();

  // State
  List<TaskModel> _tasks = [];
  bool _isFetching = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;

  // 
  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isFetching => _isFetching;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _tasks.isEmpty;

  //
  List<TaskModel> get todayTasks => _tasks.where((t) => t.isDueToday).toList();

  List<TaskModel> get overdueTasks => _tasks.where((t) => t.isOverdue).toList();

  List<TaskModel> get doneTasks =>
      _tasks.where((t) => t.status == TaskStatus.done).toList();

  /// Mengambil semua tasks dari server.
  Future<void> fetchTasks({String? authToken}) async {
    _isFetching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(authToken: authToken);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Gagal mengambil data tugas.';
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  // Membuat task baru
  Future<bool> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    DateTime? deadline,
    CategoryModel? category,
    String? authToken,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTask = await _taskService.createTask(
        title: title,
        description: description,
        priority: priority,
        deadline: deadline,
        category: category,
        authToken: authToken,
      );

      _tasks = [newTask, ..._tasks];
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal membuat tugas baru.';
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // Memperbarui tugas yang sudah
  Future<bool> updateTask({
    required String id,
    required String title,
    String? description,
    required TaskPriority priority,
    DateTime? deadline,
    CategoryModel? category,
    TaskStatus? status,
    String? authToken,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await _taskService.updateTask(
        id: id,
        title: title,
        description: description,
        priority: priority,
        deadline: deadline,
        category: category,
        status: status,
        authToken: authToken,
      );

      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        _tasks = List.from(_tasks);
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui tugas.';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Memperbarui status tugas
  Future<bool> updateTaskStatus({
    required String id,
    required TaskStatus status,
    String? authToken,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedData = await _taskService.updateTaskStatus(
        id: id,
        status: status,
        authToken: authToken,
      );

      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          title: updatedData.title,
          status: updatedData.status,
        );
        _tasks = List.from(_tasks);
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui status tugas.';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  //  Menghapus tugas
  Future<bool> deleteTask({required String id, String? authToken}) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _taskService.deleteTask(
        id: id,
        authToken: authToken,
      );

      if (success) {
        _tasks.removeWhere((t) => t.id == id);
        _tasks = List.from(_tasks);
        return true;
      }
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menghapus tugas.';
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // Membersihakan eror
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

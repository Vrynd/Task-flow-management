/// Model data untuk statistik tugas pengguna.
class UserStatisticsModel {
  final int totalTasks;
  final int completedTasks;
  final int todoTasks;
  final int inProgressTasks;
  final int lateTasks;
  final int completionRatePercentage;

  const UserStatisticsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.todoTasks,
    required this.inProgressTasks,
    required this.lateTasks,
    required this.completionRatePercentage,
  });

  factory UserStatisticsModel.fromJson(Map<String, dynamic> json) {
    return UserStatisticsModel(
      totalTasks: json['total_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      todoTasks: json['todo_tasks'] as int? ?? 0,
      inProgressTasks: json['in_progress_tasks'] as int? ?? 0,
      lateTasks: json['late_tasks'] as int? ?? 0,
      completionRatePercentage: json['completion_rate_percentage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'todo_tasks': todoTasks,
      'in_progress_tasks': inProgressTasks,
      'late_tasks': lateTasks,
      'completion_rate_percentage': completionRatePercentage,
    };
  }

  @override
  String toString() => 'UserStatisticsModel(total: $totalTasks, rate: $completionRatePercentage%)';
}

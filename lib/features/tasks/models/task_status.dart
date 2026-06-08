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

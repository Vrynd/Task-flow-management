import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_management/core/themes/app_colors.dart';
import 'package:task_management/features/auth/providers/auth_provider.dart';
import 'package:task_management/features/home/presentation/widgets/task_list_item.dart';
import 'package:task_management/features/tasks/models/task_model.dart';
import 'package:task_management/features/tasks/presentation/screens/create_task_screen.dart';
import 'package:task_management/features/tasks/presentation/widgets/status_bottom_sheet.dart';
import 'package:task_management/features/tasks/presentation/widgets/task_empty_state.dart';
import 'package:task_management/features/tasks/presentation/widgets/task_priority_filter.dart';
import 'package:task_management/features/tasks/presentation/widgets/task_search_bar.dart';
import 'package:task_management/features/tasks/presentation/widgets/task_tab_bar.dart';
import 'package:task_management/features/tasks/providers/task_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _activeTab = 0;
  TaskPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateTask(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreateTaskScreen(),
        fullscreenDialog: true,
      ),
    );

    if (result == true && mounted) {
      taskProvider.fetchTasks(authToken: auth.token, authProvider: auth);
    }
  }

  Future<void> _openEditTask(BuildContext context, TaskModel task) async {
    final auth = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(task: task),
        fullscreenDialog: true,
      ),
    );

    if (result == true && mounted) {
      taskProvider.fetchTasks(authToken: auth.token, authProvider: auth);
    }
  }

  void _showStatusBottomSheet(BuildContext context, TaskModel task) {
    StatusBottomSheet.show(context, task).then((newStatus) {
      if (newStatus is TaskStatus &&
          newStatus != task.status &&
          context.mounted) {
        final auth = context.read<AuthProvider>();
        context.read<TaskProvider>().updateTaskStatus(
          id: task.id,
          status: newStatus,
          authToken: auth.token,
          authProvider: auth,
        );
      }
    });
  }

  Future<void> _confirmDelete(BuildContext context, TaskModel task) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.slate800 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hapus Tugas',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus tugas "${task.title}" secara permanen?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.priorityHigh,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      final taskProvider = context.read<TaskProvider>();

      final success = await taskProvider.deleteTask(
        id: task.id,
        authToken: auth.token,
        authProvider: auth,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tugas berhasil dihapus',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.priorityLow,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 20,
                20,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cari & Filter Tugas',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola dan pantau semua tugas Anda',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.slate800,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Consumer<TaskProvider>(
                  builder: (context, taskProvider, _) {
                    // Filter tugas berdasarkan parameter
                    final filteredTasks = taskProvider.tasks.where((task) {
                      // 1. Tab filter (Daftar Tugas vs Selesai)
                      final matchesTab = _activeTab == 0
                          ? task.status != TaskStatus.done
                          : task.status == TaskStatus.done;

                      // 2. Search query filter
                      final matchesSearch =
                          task.title.toLowerCase().contains(_searchQuery) ||
                          (task.description ?? '').toLowerCase().contains(
                            _searchQuery,
                          );

                      // 3. Priority filter
                      final matchesPriority =
                          _selectedPriority == null ||
                          task.priority == _selectedPriority;

                      return matchesTab && matchesSearch && matchesPriority;
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab Switcher
                        TaskTabBar(
                          activeIndex: _activeTab,
                          onTabChanged: (index) {
                            setState(() {
                              _activeTab = index;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Search Bar & Priority Filter (Sejajar berdampingan)
                        Row(
                          children: [
                            Expanded(
                              child: TaskSearchBar(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.trim().toLowerCase();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            TaskPriorityFilter(
                              selectedPriority: _selectedPriority,
                              onPrioritySelected: (priority) {
                                setState(() {
                                  _selectedPriority = priority;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Text(
                                _activeTab == 0
                                    ? 'Daftar Tugas Aktif'
                                    : 'Tugas Selesai',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.indigo500.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  filteredTasks.length.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.indigo500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (_activeTab == 0)
                                InkWell(
                                  onTap: () => _openCreateTask(context),
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.indigo600,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.indigo500.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Tugas Baru',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // List Tugas (Scrollable)
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.indigo500,
                            onRefresh: () => taskProvider.fetchTasks(
                              authToken: auth.token,
                              authProvider: auth,
                            ),
                            child: taskProvider.isFetching
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.indigo500,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : filteredTasks.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      TaskEmptyState(
                                        isSearchMode:
                                            _searchQuery.isNotEmpty ||
                                            _selectedPriority != null,
                                        message:
                                            _searchQuery.isEmpty &&
                                                _selectedPriority == null
                                            ? (_activeTab == 0
                                                  ? 'Belum ada tugas aktif'
                                                  : 'Belum ada tugas selesai')
                                            : null,
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 120),
                                    itemCount: filteredTasks.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final task = filteredTasks[index];
                                      return TaskListItem(
                                        task: task,
                                        onTap: () =>
                                            _openEditTask(context, task),
                                        onStatusToggle: () =>
                                            _showStatusBottomSheet(
                                              context,
                                              task,
                                            ),
                                        onDelete: _activeTab == 1
                                            ? () =>
                                                  _confirmDelete(context, task)
                                            : null,
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

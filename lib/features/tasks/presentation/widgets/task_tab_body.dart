import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../screens/create_task_screen.dart';
import '../../../home/presentation/widgets/task_list_item.dart';
import '../../../home/presentation/widgets/custom_fab_location.dart';

class TasksTabBody extends StatefulWidget {
  const TasksTabBody({super.key});

  @override
  State<TasksTabBody> createState() => _TasksTabBodyState();
}

class _TasksTabBodyState extends State<TasksTabBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Filters
  TaskPriority? _selectedPriority; // null means "Semua"
  TaskStatus? _selectedStatus; // null means "Semua"

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
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
      taskProvider.fetchTasks(authToken: auth.token);
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
      taskProvider.fetchTasks(authToken: auth.token);
    }
  }

  void _showStatusBottomSheet(BuildContext context, TaskModel task) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.slate800 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ubah Status Tugas',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                _StatusOption(
                  label: 'Belum Mulai',
                  description: 'Tugas belum dikerjakan',
                  icon: Icons.radio_button_unchecked_rounded,
                  color: AppColors.slate400,
                  isActive: task.status == TaskStatus.todo,
                  onTap: () => Navigator.of(context).pop(TaskStatus.todo),
                ),
                const SizedBox(height: 12),
                _StatusOption(
                  label: 'Sedang Dikerjakan',
                  description: 'Tugas sedang aktif dikerjakan',
                  icon: Icons.hourglass_empty_rounded,
                  color: AppColors.priorityMedium,
                  isActive: task.status == TaskStatus.inProgress,
                  onTap: () => Navigator.of(context).pop(TaskStatus.inProgress),
                ),
                const SizedBox(height: 12),
                _StatusOption(
                  label: 'Selesai',
                  description: 'Tugas telah selesai dikerjakan',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.priorityLow,
                  isActive: task.status == TaskStatus.done,
                  onTap: () => Navigator.of(context).pop(TaskStatus.done),
                ),
              ],
            ),
          ),
        );
      },
    ).then((newStatus) {
      if (newStatus is TaskStatus && newStatus != task.status && context.mounted) {
        final auth = context.read<AuthProvider>();
        context.read<TaskProvider>().updateTaskStatus(
              id: task.id,
              status: newStatus,
              authToken: auth.token,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openCreateTask(context),
        backgroundColor: AppColors.indigo600,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Tugas Baru',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: const CustomFabLocation(),
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, _) {
            // Filter tasks locally
            final filteredTasks = taskProvider.tasks.where((task) {
              // Search query filter
              final matchesSearch = task.title.toLowerCase().contains(_searchQuery) ||
                  (task.description ?? '').toLowerCase().contains(_searchQuery);
              
              // Priority filter
              final matchesPriority = _selectedPriority == null || task.priority == _selectedPriority;
              
              // Status filter
              final matchesStatus = _selectedStatus == null || task.status == _selectedStatus;

              return matchesSearch && matchesPriority && matchesStatus;
            }).toList();

            return RefreshIndicator(
              color: AppColors.indigo500,
              onRefresh: () => taskProvider.fetchTasks(authToken: auth.token),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cari & Filter Tugas',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Temukan tugas Anda dengan cepat',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate800 : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.slate700 : AppColors.slate200,
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Cari tugas...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedSearch01,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 46),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Filter Section - Prioritas
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Text(
                            'Prioritas',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _buildPriorityFilterChip('Semua', null),
                              _buildPriorityFilterChip('Tinggi', TaskPriority.high),
                              _buildPriorityFilterChip('Sedang', TaskPriority.medium),
                              _buildPriorityFilterChip('Rendah', TaskPriority.low),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Section - Status
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Text(
                            'Status',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _buildStatusFilterChip('Semua', null),
                              _buildStatusFilterChip('Belum Mulai', TaskStatus.todo),
                              _buildStatusFilterChip('Sedang Dikerjakan', TaskStatus.inProgress),
                              _buildStatusFilterChip('Selesai', TaskStatus.done),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Results Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            'Hasil Pencarian',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.indigo500.withValues(alpha: 0.1),
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
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Task List
                  if (taskProvider.isFetching)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.indigo500,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    )
                  else if (filteredTasks.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.indigo500.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedSearch01,
                                size: 28,
                                color: AppColors.indigo500.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tugas tidak ditemukan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Coba kata kunci lain atau ubah filter Anda',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                      sliver: SliverList.separated(
                        itemCount: filteredTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return TaskListItem(
                            task: task,
                            onTap: () => _openEditTask(context, task),
                            onStatusToggle: () => _showStatusBottomSheet(context, task),
                            onDelete: task.status == TaskStatus.done
                                ? () => _confirmDelete(context, task)
                                : null,
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPriorityFilterChip(String label, TaskPriority? priority) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedPriority == priority;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedPriority = priority);
          }
        },
        selectedColor: AppColors.indigo500,
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected
                ? AppColors.indigo500
                : (isDark ? AppColors.slate700 : AppColors.slate200),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, TaskStatus? status) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedStatus == status;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedStatus = status);
          }
        },
        selectedColor: AppColors.indigo500,
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected
                ? AppColors.indigo500
                : (isDark ? AppColors.slate700 : AppColors.slate200),
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.08)
              : (isDark ? AppColors.slate700.withValues(alpha: 0.3) : AppColors.slate100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? color
                : (isDark ? AppColors.slate700 : AppColors.slate200),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.15) : theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? color : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

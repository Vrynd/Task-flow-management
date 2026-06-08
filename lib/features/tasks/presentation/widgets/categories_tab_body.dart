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

class CategoriesTabBody extends StatefulWidget {
  const CategoriesTabBody({super.key});

  @override
  State<CategoriesTabBody> createState() => _CategoriesTabBodyState();
}

class _CategoriesTabBodyState extends State<CategoriesTabBody> {
  // Common callbacks for tasks inside bottom sheet
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
                _StatusOptionItem(
                  label: 'Belum Mulai',
                  description: 'Tugas belum dikerjakan',
                  icon: Icons.radio_button_unchecked_rounded,
                  color: AppColors.slate400,
                  isActive: task.status == TaskStatus.todo,
                  onTap: () => Navigator.of(context).pop(TaskStatus.todo),
                ),
                const SizedBox(height: 12),
                _StatusOptionItem(
                  label: 'Sedang Dikerjakan',
                  description: 'Tugas sedang aktif dikerjakan',
                  icon: Icons.hourglass_empty_rounded,
                  color: AppColors.priorityMedium,
                  isActive: task.status == TaskStatus.inProgress,
                  onTap: () => Navigator.of(context).pop(TaskStatus.inProgress),
                ),
                const SizedBox(height: 12),
                _StatusOptionItem(
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

  void _showCategoryTasksBottomSheet(BuildContext context, CategoryModel category, List<TaskModel> categoryTasks) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catColor = category.toFlutterColor();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.slate900 : AppColors.slate50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<TaskProvider>(
              builder: (context, taskProvider, _) {
                // Re-filter inside the bottom sheet builder to keep it reactive to status changes/deletions
                final reactiveTasks = taskProvider.tasks
                    .where((t) => t.category?.name.toLowerCase().trim() == category.name.toLowerCase().trim())
                    .toList();

                return Column(
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 24,
                            decoration: BoxDecoration(
                              color: catColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${reactiveTasks.length} Tugas',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 1),

                    // Task List
                    Expanded(
                      child: reactiveTasks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.playlist_add_check_rounded,
                                    size: 48,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Semua tugas telah dihapus/selesai',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.all(20),
                              itemCount: reactiveTasks.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final task = reactiveTasks[index];
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
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, _) {
            // Extract unique categories
            final categoriesMap = <String, CategoryModel>{};
            for (final task in taskProvider.tasks) {
              if (task.category != null) {
                final normalized = task.category!.name.toLowerCase().trim();
                categoriesMap[normalized] = task.category!;
              }
            }
            final categoriesList = categoriesMap.values.toList();

            return CustomScrollView(
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
                          'Kategori Tugas',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola dan pantau tugas berdasarkan topik',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Grid of Categories
                if (taskProvider.isFetching)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.indigo500,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                else if (categoriesList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.indigo500.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedDashboardSquare01,
                              size: 32,
                              color: AppColors.indigo500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada kategori',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Buat tugas baru dan tambahkan nama kategori untuk memulainya.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.4,
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
                    sliver: SliverGrid.builder(
                      itemCount: categoriesList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                      ),
                      itemBuilder: (context, index) {
                        final category = categoriesList[index];
                        final catColor = category.toFlutterColor();

                        // Calculate stats for this category
                        final categoryTasks = taskProvider.tasks
                            .where((t) => t.category?.name.toLowerCase().trim() == category.name.toLowerCase().trim())
                            .toList();
                        
                        final totalTasks = categoryTasks.length;
                        final doneTasks = categoryTasks.where((t) => t.status == TaskStatus.done).length;
                        final progress = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;

                        return InkWell(
                          onTap: () => _showCategoryTasksBottomSheet(context, category, categoryTasks),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.slate800 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category color dot / icon header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: catColor.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: catColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12,
                                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                                const Spacer(),

                                // Name
                                Text(
                                  category.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),

                                // Task counts
                                Text(
                                  '$doneTasks / $totalTasks Selesai',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 4,
                                    backgroundColor: isDark ? AppColors.slate700 : AppColors.slate100,
                                    valueColor: AlwaysStoppedAnimation<Color>(catColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusOptionItem extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusOptionItem({
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

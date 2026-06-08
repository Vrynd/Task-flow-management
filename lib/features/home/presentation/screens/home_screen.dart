import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_management/core/themes/app_colors.dart';
import 'package:task_management/core/themes/app_theme.dart';
import 'package:task_management/features/auth/providers/auth_provider.dart';
import 'package:task_management/features/home/presentation/widgets/home_empty_state.dart';
import 'package:task_management/features/home/presentation/widgets/home_header.dart';
import 'package:task_management/features/home/presentation/widgets/status_bottom_sheet.dart';
import 'package:task_management/features/home/presentation/widgets/task_list_item.dart';
import 'package:task_management/features/tasks/models/task_model.dart';
import 'package:task_management/features/tasks/presentation/screens/create_task_screen.dart';
import 'package:task_management/features/tasks/providers/task_provider.dart';



class HomeScreen extends StatefulWidget {
  final bool isMenuMode;
  const HomeScreen({super.key, this.isMenuMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      context.read<TaskProvider>().fetchTasks(authToken: auth.token);
    });
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
    StatusBottomSheet.show(context, task).then((newStatus) {
      if (newStatus is TaskStatus &&
          newStatus != task.status &&
          context.mounted) {
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
    // Cek apakah sistem menggunakan mode gelap secara global
    final isSystemDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: SafeArea(
        top:
            false, // Biar background putih/slate800 header menyentuh bagian paling atas status bar
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, _) {
            // Filter tugas hari ini (Today's Tasks) saja
            final todayTasks = taskProvider.tasks
                .where((t) => t.isDueToday)
                .toList();

            // Filter berdasarkan kata kunci pencarian
            final filteredTasks = todayTasks
                .where(
                  (t) => t.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();

            final totalToday = todayTasks.length;
            final completedToday = todayTasks
                .where((t) => t.status == TaskStatus.done)
                .length;

            return RefreshIndicator(
              color: AppColors.indigo500,
              onRefresh: () => taskProvider.fetchTasks(authToken: auth.token),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSystemDark ? AppColors.slate800 : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                        boxShadow: isSystemDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      padding: EdgeInsets.fromLTRB(
                        20,
                        MediaQuery.of(context).padding.top + 20,
                        20,
                        24,
                      ),
                      child: Theme(
                        data: isSystemDark
                            ? AppTheme.darkTheme
                            : AppTheme.lightTheme,
                        child: Builder(
                          builder: (headerContext) {
                            return HomeHeader(
                              user: auth.currentUser,
                              totalTasks: totalToday,
                              completedTasks: completedToday,
                              onSearchChanged: (query) {
                                setState(() {
                                  _searchQuery = query;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Judul Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            _searchQuery.isEmpty
                                ? 'Tugas Hari Ini'
                                : 'Hasil Pencarian',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
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
                              color: AppColors.indigo500.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              filteredTasks.length.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: HomeEmptyState(
                          message: _searchQuery.isEmpty
                              ? 'Tidak ada tugas hari ini'
                              : 'Tugas tidak ditemukan',
                          subtitle: _searchQuery.isEmpty
                              ? 'Nikmati hari Anda, atau ketuk tombol "+" untuk menambahkan tugas.'
                              : 'Coba gunakan kata kunci pencarian lain.',
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
                            onStatusToggle: () =>
                                _showStatusBottomSheet(context, task),
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
}

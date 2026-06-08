import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../tasks/models/task_model.dart';

/// Modal bottom sheet kustom untuk memilih atau mengubah status tugas.
class StatusBottomSheet extends StatelessWidget {
  final TaskModel task;

  const StatusBottomSheet({super.key, required this.task});

  /// Menampilkan bottom sheet dan mengembalikan status yang dipilih.
  static Future<TaskStatus?> show(BuildContext context, TaskModel task) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<TaskStatus>(
      context: context,
      backgroundColor: isDark ? AppColors.slate800 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatusBottomSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar di atas bottom sheet
            Center(
              child: Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ubah Status Tugas',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.1,
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
              description: 'Tugas baru dan belum mulai dikerjakan',
              icon: HugeIcons.strokeRoundedCircle,
              color: AppColors.slate400,
              isActive: task.status == TaskStatus.todo,
              onTap: () => Navigator.of(context).pop(TaskStatus.todo),
            ),
            const SizedBox(height: 12),
            _StatusOption(
              label: 'Sedang Dikerjakan',
              description: 'Tugas saat ini sedang aktif dikerjakan',
              icon: HugeIcons.strokeRoundedHourglass,
              color: AppColors.priorityMedium,
              isActive: task.status == TaskStatus.inProgress,
              onTap: () => Navigator.of(context).pop(TaskStatus.inProgress),
            ),
            const SizedBox(height: 12),
            _StatusOption(
              label: 'Selesai',
              description: 'Tugas telah rampung diselesaikan',
              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
              color: AppColors.priorityLow,
              isActive: task.status == TaskStatus.done,
              onTap: () => Navigator.of(context).pop(TaskStatus.done),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final String description;
  final List<List<dynamic>> icon;
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.08)
              : (isDark ? AppColors.slate700.withValues(alpha: 0.2) : AppColors.slate100),
          borderRadius: BorderRadius.circular(16),
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
              child: HugeIcon(
                icon: icon,
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
              HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

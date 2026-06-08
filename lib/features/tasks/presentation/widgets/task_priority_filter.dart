import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../models/task_model.dart';

/// Tombol filter prioritas berbentuk Capsule yang memicu Bottom Sheet.
class TaskPriorityFilter extends StatelessWidget {
  final TaskPriority? selectedPriority;
  final ValueChanged<TaskPriority?> onPrioritySelected;

  const TaskPriorityFilter({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  String _getPriorityLabel(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Tinggi';
      case TaskPriority.medium:
        return 'Sedang';
      case TaskPriority.low:
        return 'Rendah';
      case null:
        return 'Semua';
    }
  }

  Color _getPriorityColor(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
      case null:
        return AppColors.indigo500;
    }
  }

  void _showPriorityBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.slate800 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
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
                  'Pilih Prioritas',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Saring tugas Anda berdasarkan tingkat prioritas',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPriorityOption(context, null, 'Semua', 'Tampilkan semua tugas tanpa membedakan prioritas'),
                const SizedBox(height: 12),
                _buildPriorityOption(context, TaskPriority.high, 'Tinggi', 'Prioritas utama yang mendesak'),
                const SizedBox(height: 12),
                _buildPriorityOption(context, TaskPriority.medium, 'Sedang', 'Prioritas menengah untuk diselesaikan'),
                const SizedBox(height: 12),
                _buildPriorityOption(context, TaskPriority.low, 'Rendah', 'Prioritas santai dengan tenggat longgar'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityOption(
    BuildContext context,
    TaskPriority? priority,
    String label,
    String description,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedPriority == priority;
    final color = _getPriorityColor(priority);

    return InkWell(
      onTap: () {
        onPrioritySelected(priority);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : (isDark ? AppColors.slate700.withValues(alpha: 0.2) : AppColors.slate100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.slate700 : AppColors.slate200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
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
            if (isSelected)
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getPriorityColor(selectedPriority);
    final label = _getPriorityLabel(selectedPriority);

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => _showPriorityBottomSheet(context),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.slate900.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.slate700.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indikator warna prioritas aktif
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Prioritas: $label',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowDown01,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

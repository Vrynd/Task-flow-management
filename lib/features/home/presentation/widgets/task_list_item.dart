import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../tasks/models/task_model.dart';
import '../../../tasks/presentation/widgets/category_form.dart';

/// Widget card satu item task di list home.
///
/// Menampilkan: judul, kategori badge, priority badge, deadline.
/// Smart: tap untuk aksi (detail — placeholder).
class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onStatusToggle;
  final VoidCallback? onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = task.status == TaskStatus.done;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 16, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.status == TaskStatus.inProgress
                ? AppColors.indigo500.withValues(alpha: 0.6)
                : (isDark ? AppColors.slate700 : AppColors.slate200),
            width: task.status == TaskStatus.inProgress ? 1.5 : 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox Status ──────────────────────────────
            _StatusCheckbox(
              status: task.status,
              onTap: onStatusToggle,
            ),

            // ── Konten Utama ────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Priority + Status
                  Row(
                    children: [
                      _PriorityBadge(priority: task.priority),
                      if (task.status == TaskStatus.inProgress) ...[
                        const SizedBox(width: 6),
                        _StatusChip(
                          label: 'Sedang Dikerjakan',
                          color: AppColors.priorityMedium,
                        ),
                      ],
                      const Spacer(),
                      if (isCompleted && onDelete != null)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.priorityHigh,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onDelete,
                        )
                      else if (task.isOverdue)
                        _StatusChip(
                          label: 'Terlambat',
                          color: AppColors.priorityHigh,
                        )
                      else if (task.isDueToday)
                        _StatusChip(
                          label: 'Hari Ini',
                          color: AppColors.priorityMedium,
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Judul
                  Text(
                    task.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                          : theme.colorScheme.onSurface,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Deskripsi
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isCompleted
                            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                            : theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Footer: Kategori + Deadline
                  Row(
                    children: [
                      // Kategori badge
                      if (task.category != null)
                        CategoryBadge(
                          name: task.category!.name,
                          color: task.category!.toFlutterColor().withValues(
                            alpha: isCompleted ? 0.4 : 1.0,
                          ),
                        ),

                      const Spacer(),

                      // Deadline
                      if (task.deadline != null)
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: task.isOverdue
                                  ? AppColors.priorityHigh
                                  : theme.colorScheme.onSurfaceVariant.withValues(
                                      alpha: isCompleted ? 0.4 : 1.0,
                                    ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('d MMM', 'id_ID').format(task.deadline!),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: task.isOverdue
                                    ? AppColors.priorityHigh
                                    : theme.colorScheme.onSurfaceVariant.withValues(
                                        alpha: isCompleted ? 0.4 : 1.0,
                                      ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Priority Badge ───────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: priority.color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Chip ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Status Checkbox ─────────────────────────────────────────────────────────

class _StatusCheckbox extends StatelessWidget {
  final TaskStatus status;
  final VoidCallback? onTap;

  const _StatusCheckbox({required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDone = status == TaskStatus.done;
    final isProgress = status == TaskStatus.inProgress;

    Color color;
    IconData? icon;

    if (isDone) {
      color = AppColors.priorityLow;
      icon = Icons.check_rounded;
    } else if (isProgress) {
      color = AppColors.priorityMedium;
      icon = Icons.hourglass_empty_rounded;
    } else {
      color = AppColors.slate400;
      icon = null;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 2, 12, 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? color : (isProgress ? color : color.withValues(alpha: 0.6)),
              width: 2,
            ),
          ),
          child: icon != null
              ? Icon(
                  icon,
                  size: 14,
                  color: isDone ? Colors.white : color,
                )
              : null,
        ),
      ),
    );
  }
}

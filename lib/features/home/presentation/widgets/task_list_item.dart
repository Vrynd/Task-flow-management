import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../tasks/models/task_model.dart';

/// Widget card satu item task di list home dan tasks screen.
///
/// Menggunakan premium layout:
/// - Kiri: Sidebar deadline vertikal dengan RotatedBox.
/// - Kanan: Judul, deskripsi, kategori badge di atas, serta prioritas pill dan status checkbox di bawah.
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
    final isInProgress = task.status == TaskStatus.inProgress;

    // Menentukan warna background sidebar kiri berdasarkan status
    Color sidebarBgColor;
    if (isCompleted) {
      sidebarBgColor = AppColors.slate700.withValues(alpha: 0.3);
    } else if (isInProgress) {
      sidebarBgColor = AppColors.indigo500;
    } else {
      sidebarBgColor = AppColors.slate900.withValues(alpha: 0.8);
    }

    // Menentukan teks deadline vertikal
    String sidebarText;
    if (task.deadline != null) {
      sidebarText = DateFormat('d MMM', 'id_ID').format(task.deadline!).toUpperCase();
    } else {
      sidebarText = 'TUGAS';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: sidebarBgColor, // Menggunakan warna sidebar sebagai latar dasar parent
        borderRadius: BorderRadius.circular(20),
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
      clipBehavior: Clip.antiAlias, // Memotong area keluar mengikuti border radius luar
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Left Sidebar (Vertical Deadline) ───────────────────
            SizedBox(
              width: 52,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3, // Rotasi -90 derajat (membaca dari bawah ke atas)
                  child: Text(
                    sidebarText,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? Colors.white.withValues(alpha: 0.6) : Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // ─── Right Content Area (Rounded Overlap Card) ─────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : Colors.white,
                  borderRadius: BorderRadius.circular(20), // Membuat overlap bertumpuk di sebelah kiri
                  border: Border.all(
                    color: isInProgress
                        ? AppColors.indigo500.withValues(alpha: 0.5)
                        : (isDark ? AppColors.slate700.withValues(alpha: 0.7) : AppColors.slate200),
                    width: isInProgress ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Baris Atas: Judul & Kategori
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
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
                                ),
                                if (task.category != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: task.category!.toFlutterColor().withValues(
                                        alpha: isCompleted ? 0.08 : 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: task.category!.toFlutterColor().withValues(
                                          alpha: isCompleted ? 0.15 : 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      task.category!.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isCompleted
                                            ? task.category!.toFlutterColor().withValues(alpha: 0.5)
                                            : task.category!.toFlutterColor(),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // Deskripsi Tugas
                            if (task.description != null && task.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
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
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Baris Bawah: Prioritas & Aksi Checkbox
                        Row(
                          children: [
                            // Priority Badge (Capsule style)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: task.priority.color.withValues(
                                  alpha: isCompleted ? 0.08 : 0.15,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? task.priority.color.withValues(alpha: 0.5)
                                          : task.priority.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    task.priority.label,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isCompleted
                                          ? task.priority.color.withValues(alpha: 0.5)
                                          : task.priority.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Aksi Tambahan: Hapus (khusus tugas Selesai)
                            if (isCompleted && onDelete != null) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.priorityHigh,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: onDelete,
                              ),
                              const SizedBox(width: 12),
                            ],

                            // Checkbox Status
                            _StatusCheckbox(
                              status: task.status,
                              onTap: onStatusToggle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    );
  }
}

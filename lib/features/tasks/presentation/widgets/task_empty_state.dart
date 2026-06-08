import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/themes/app_colors.dart';

/// Widget Empty State dengan garis luar bermotif dashed (putus-putus) kustom untuk menu Task.
class TaskEmptyState extends StatelessWidget {
  final bool isSearchMode;
  final String? message;
  final String? subtitle;

  const TaskEmptyState({
    super.key,
    this.isSearchMode = false,
    this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String displayMessage = message ?? (isSearchMode ? 'Tugas tidak ditemukan' : 'Belum ada tugas');
    final String displaySubtitle = subtitle ?? (isSearchMode
        ? 'Coba gunakan kata kunci pencarian lain atau ubah filter prioritas Anda.'
        : 'Semua rencana Anda bersih. Mulai hari ini dengan menambahkan tugas baru.');

    final displayIcon = isSearchMode
        ? HugeIcons.strokeRoundedSearch01
        : HugeIcons.strokeRoundedTask02;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: isDark ? AppColors.slate700.withValues(alpha: 0.5) : AppColors.slate300,
          strokeWidth: 1.5,
          gap: 6.0,
          dashLength: 8.0,
          borderRadius: 24.0,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.slate800.withValues(alpha: 0.2)
                : AppColors.slate100.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container lingkaran dengan soft shadow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.indigo500.withValues(alpha: 0.08)
                      : AppColors.indigo50.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.indigo500.withValues(alpha: 0.15)
                        : AppColors.indigo100.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: displayIcon,
                    size: 32,
                    color: AppColors.indigo500.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                displayMessage,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  displaySubtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter kustom untuk menggambar garis luar bertipe dashed dengan sudut membulat.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
    this.dashLength = 8.0,
    this.borderRadius = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = _getDashedPath(path, dashLength, gap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _getDashedPath(Path source, double dashLength, double gap) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashLength : gap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}

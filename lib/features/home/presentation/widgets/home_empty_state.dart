import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../../core/themes/app_colors.dart';

/// Widget Empty State dengan visualisasi yang modern dan minimalis.
class HomeEmptyState extends StatelessWidget {
  final String message;
  final String subtitle;

  const HomeEmptyState({
    super.key,
    required this.message,
    this.subtitle = 'Tugas yang dijadwalkan hari ini akan muncul di sini',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container lingkaran dengan soft shadow
            Container(
              width: 90,
              height: 90,
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
                  icon: HugeIcons.strokeRoundedCalendar03,
                  size: 36,
                  color: AppColors.indigo500.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

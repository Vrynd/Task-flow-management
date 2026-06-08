import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:task_management/features/auth/models/user_model.dart';
import '../../../../../core/themes/app_colors.dart';

/// Widget Header Dashboard utama untuk halaman Home.
/// 
/// Menggabungkan 3 fungsi utama yang disesuaikan dengan Design System (Indigo Aurora):
/// 1. Greeting & User Profile dengan Action Icons (Settings/Notifikasi).
/// 2. Search Bar untuk mencari tugas.
/// 3. Ringkasan Tugas (Total & Selesai) menggunakan skema warna tema yang kohesif.
class HomeHeader extends StatefulWidget {
  final UserModel? user;
  final int totalTasks;
  final int completedTasks;
  final ValueChanged<String> onSearchChanged;

  const HomeHeader({
    super.key,
    this.user,
    required this.totalTasks,
    required this.completedTasks,
    required this.onSearchChanged,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String get _greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour < 11) return '☀️';
    if (hour < 15) return '⛅';
    if (hour < 18) return '🌇';
    return '🌙';
  }

  String get _initials {
    final name = widget.user?.name ?? 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasAvatar = widget.user?.avatarUrl != null && widget.user!.avatarUrl!.trim().isNotEmpty;

    // Menyesuaikan warna Summary Card dengan Design System (Indigo Aurora)
    // 1. Total Tasks Card: Menggunakan warna brand utama (Indigo)
    final totalCardBg = isDark ? AppColors.indigo900.withValues(alpha: 0.4) : AppColors.indigo50;
    final totalCardText = isDark ? AppColors.indigo100 : AppColors.indigo900;
    final totalCardBorder = Border.all(
      color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.15),
      width: 1.5,
    );
    final totalButtonBg = theme.colorScheme.primary;
    final totalButtonArrow = theme.colorScheme.onPrimary;

    // 2. Completed Tasks Card: Menggunakan warna status sukses (Emerald/Green)
    final completedCardBg = AppColors.priorityLow.withValues(alpha: isDark ? 0.12 : 0.08);
    final completedCardText = isDark ? AppColors.priorityLow : const Color(0xFF0F766E); // Emerald 700 untuk kontras teks yang baik
    final completedCardBorder = Border.all(
      color: AppColors.priorityLow.withValues(alpha: isDark ? 0.35 : 0.2),
      width: 1.5,
    );
    final completedButtonBg = AppColors.priorityLow;
    final completedButtonArrow = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row 1: Profile & Greeting & Action Buttons ────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar di kiri dengan gradient border kohesif
            GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: hasAvatar
                      ? null
                      : LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  shape: BoxShape.circle,
                  image: hasAvatar
                      ? DecorationImage(
                          image: NetworkImage(widget.user!.avatarUrl!),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                  border: Border.all(
                    color: isDark ? theme.colorScheme.primary.withValues(alpha: 0.5) : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: hasAvatar
                    ? null
                    : Center(
                        child: Text(
                          _initials,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Greeting & Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_greeting $_greetingEmoji',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.user?.name ?? 'Pengguna',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Action Buttons
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : AppColors.slate100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedComment01,
                  color: theme.colorScheme.onSurface,
                  size: 18,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Fitur Chat akan segera hadir!',
                        style: GoogleFonts.poppins(),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate900 : AppColors.slate100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedNotification03,
                      color: theme.colorScheme.onSurface,
                      size: 18,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Belum ada notifikasi baru',
                            style: GoogleFonts.poppins(),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                // Red badge
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.priorityHigh,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Row 2: Search Bar ─────────────────────────────────────────
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate900 : AppColors.slate100,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearchChanged,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari tugas hari ini...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                    setState(() {});
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Row 3: Summary Cards ──────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _DashboardSummaryCard(
                value: widget.totalTasks.toString().padLeft(2, '0'),
                label: 'Total Tugas',
                backgroundColor: totalCardBg,
                textColor: totalCardText,
                border: totalCardBorder,
                buttonColor: totalButtonBg,
                arrowColor: totalButtonArrow,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardSummaryCard(
                value: widget.completedTasks.toString().padLeft(2, '0'),
                label: 'Tugas Selesai',
                backgroundColor: completedCardBg,
                textColor: completedCardText,
                border: completedCardBorder,
                buttonColor: completedButtonBg,
                arrowColor: completedButtonArrow,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Card ringkasan yang disesuaikan dengan skema warna Design System.
class _DashboardSummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Border? border;
  final Color buttonColor;
  final Color arrowColor;
  final VoidCallback onTap;

  const _DashboardSummaryCard({
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.border,
    required this.buttonColor,
    required this.arrowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Tombol melingkar dengan ikon panah yang serasi
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: arrowColor,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:task_management/features/auth/models/user_model.dart';

import '../../../../../core/themes/app_colors.dart';


/// Widget header halaman Home.
///
/// Menampilkan greeting dinamis sesuai waktu, nama user, dan tanggal hari ini.
class HomeHeader extends StatelessWidget {
  final UserModel? user;

  const HomeHeader({super.key, this.user});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String get _todayLabel {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  String get _initials {
    final name = user?.name ?? 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Text Content ──────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.name ?? 'Pengguna',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _todayLabel,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ── Avatar ───────────────────────────────────────────
        GestureDetector(
          onTap: () => context.push('/settings'),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: hasAvatar
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.indigo500, AppColors.indigo600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              shape: BoxShape.circle,
              image: hasAvatar
                  ? DecorationImage(
                      image: NetworkImage(user!.avatarUrl!),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.indigo500.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
      ],
    );
  }
}

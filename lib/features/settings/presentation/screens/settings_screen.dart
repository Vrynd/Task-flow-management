import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/user_activity_model.dart';
import '../../models/user_statistics_model.dart';
import '../../providers/settings_provider.dart';

/// Halaman Pengaturan & Profil Pengguna.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      context.read<SettingsProvider>().fetchSettingsData(
            authToken: auth.token,
            authProvider: auth,
          );
    });
  }

  Future<void> _handleRefresh() async {
    final auth = context.read<AuthProvider>();
    await context.read<SettingsProvider>().fetchSettingsData(
          authToken: auth.token,
          authProvider: auth,
        );
  }

  void _showEditProfileBottomSheet(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final user = auth.currentUser;

    if (user == null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.slate800 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _EditProfileFormSheet(
          initialName: user.name,
          initialAvatarUrl: user.avatarUrl ?? '',
          onSave: (name, password, avatarUrl) async {
            final success = await settingsProvider.updateProfile(
              name: name,
              password: password.trim().isEmpty ? null : password,
              avatarUrl: avatarUrl.trim().isEmpty ? null : avatarUrl,
              authToken: auth.token,
              authProvider: auth,
            );

            if (success && context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Profil berhasil diperbarui',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppColors.priorityLow,
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        title: Text(
          'Profil & Pengaturan',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.profile == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.indigo500,
                strokeWidth: 2.5,
              ),
            );
          }

          if (provider.errorMessage != null && provider.profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.priorityHigh,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleRefresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Coba Lagi',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.indigo500,
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section 1: Profil User Card ─────────────────────────────
                  if (user != null) _UserProfileCard(
                    user: user,
                    onEditTap: () => _showEditProfileBottomSheet(context),
                    onLogoutTap: () {
                      authProvider.logout();
                      Navigator.of(context).pop();
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Section 2: Statistik Dashboard ──────────────────────────
                  if (provider.statistics != null) ...[
                    Text(
                      'Statistik Tugas Anda',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatisticsSection(stats: provider.statistics!),
                    const SizedBox(height: 24),
                  ],

                  // ── Section 3: Log Aktivitas ───────────────────────────────
                  Text(
                    'Aktivitas Terbaru',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.activities.isEmpty)
                    _EmptyActivitiesCard()
                  else
                    _ActivitiesList(activities: provider.activities),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── User Profile Card ───────────────────────────────────────────────────────

class _UserProfileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditTap;
  final VoidCallback onLogoutTap;

  const _UserProfileCard({
    required this.user,
    required this.onEditTap,
    required this.onLogoutTap,
  });

  String get _initials {
    final name = user.name;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
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
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
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
                          image: NetworkImage(user.avatarUrl!),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                child: hasAvatar
                    ? null
                    : Center(
                        child: Text(
                          _initials,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bergabung sejak: ${DateFormat('d MMMM yyyy', 'id_ID').format(user.createdAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              // Edit Profile Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEditTap,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(
                    'Edit Profil',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: isDark ? AppColors.slate700 : AppColors.slate300,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Logout Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onLogoutTap,
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: Text(
                    'Keluar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.priorityHigh.withValues(alpha: 0.1),
                    foregroundColor: AppColors.priorityHigh,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Statistics Section Widgets ──────────────────────────────────────────────

class _StatisticsSection extends StatelessWidget {
  final UserStatisticsModel stats;

  const _StatisticsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Row 1: Big Completion Rate Card ─────────────────
        _CompletionRateCard(percentage: stats.completionRatePercentage),
        
        const SizedBox(height: 12),

        // ── Row 2: Grid of stats ─────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatGridCard(
                label: 'Total Tugas',
                value: stats.totalTasks,
                color: AppColors.indigo500,
                icon: Icons.checklist_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatGridCard(
                label: 'Selesai',
                value: stats.completedTasks,
                color: AppColors.priorityLow,
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatGridCard(
                label: 'Belum Mulai',
                value: stats.todoTasks,
                color: AppColors.slate400,
                icon: Icons.radio_button_unchecked_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatGridCard(
                label: 'Sedang Dikerjakan',
                value: stats.inProgressTasks,
                color: AppColors.priorityMedium,
                icon: Icons.hourglass_empty_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatGridCard(
                label: 'Terlambat',
                value: stats.lateTasks,
                color: AppColors.priorityHigh,
                icon: Icons.warning_amber_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompletionRateCard extends StatelessWidget {
  final int percentage;

  const _CompletionRateCard({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tingkat Penyelesaian',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Anda telah menyelesaikan $percentage% dari seluruh tugas Anda.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor: isDark ? AppColors.slate700 : AppColors.slate100,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigo500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 6,
                  backgroundColor: isDark ? AppColors.slate700 : AppColors.slate100,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigo500),
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _StatGridCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatGridCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              Text(
                value.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── User Activities Section Widgets ─────────────────────────────────────────

class _EmptyActivitiesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          Text(
            'Belum ada aktivitas',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Semua riwayat aktivitas Anda akan terekam di sini.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActivitiesList extends StatelessWidget {
  final List<UserActivityModel> activities;

  const _ActivitiesList({required this.activities});

  IconData _getActivityIcon(String actionType) {
    switch (actionType) {
      case 'CREATE_TASK':
        return Icons.add_task_rounded;
      case 'UPDATE_TASK':
        return Icons.edit_note_rounded;
      case 'UPDATE_TASK_STATUS':
        return Icons.swap_horiz_rounded;
      case 'DELETE_TASK':
        return Icons.delete_sweep_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getActivityColor(String actionType) {
    switch (actionType) {
      case 'CREATE_TASK':
        return AppColors.indigo500;
      case 'UPDATE_TASK':
        return AppColors.priorityMedium;
      case 'UPDATE_TASK_STATUS':
        return AppColors.priorityLow;
      case 'DELETE_TASK':
        return AppColors.priorityHigh;
      default:
        return AppColors.slate500;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return DateFormat('d MMM HH:mm', 'id_ID').format(dateTime);
    }
  }

  String _getFriendlyDescription(String description) {
    var desc = description;
    
    // Ganti status teknis dengan istilah Indonesia yang ramah
    desc = desc.replaceAll('TODO', 'Belum Mulai');
    desc = desc.replaceAll('IN_PROGRESS', 'Sedang Dikerjakan');
    desc = desc.replaceAll('DONE', 'Selesai');
    
    // Sederhanakan frase perubahan status dari format teknis
    desc = desc.replaceAll('dari Belum Mulai ke Sedang Dikerjakan', 'menjadi Sedang Dikerjakan');
    desc = desc.replaceAll('dari Sedang Dikerjakan ke Selesai', 'menjadi Selesai');
    desc = desc.replaceAll('dari Belum Mulai ke Selesai', 'menjadi Selesai');
    desc = desc.replaceAll('dari Selesai ke Belum Mulai', 'menjadi Belum Mulai');
    desc = desc.replaceAll('dari Sedang Dikerjakan ke Belum Mulai', 'menjadi Belum Mulai');
    desc = desc.replaceAll('dari Selesai ke Sedang Dikerjakan', 'menjadi Sedang Dikerjakan');

    return desc;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Menampilkan maksimal 10 aktivitas terbaru agar tetap rapi
    final displayedList = activities.take(10).toList();

    return Container(
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
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayedList.length,
        separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
        itemBuilder: (context, index) {
          final act = displayedList[index];
          final color = _getActivityColor(act.actionType);
          final icon = _getActivityIcon(act.actionType);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFriendlyDescription(act.description),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeAgo(act.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Edit Profile Form Sheet ──────────────────────────────────────────────────

class _EditProfileFormSheet extends StatefulWidget {
  final String initialName;
  final String initialAvatarUrl;
  final Future<void> Function(String name, String password, String avatarUrl) onSave;

  const _EditProfileFormSheet({
    required this.initialName,
    required this.initialAvatarUrl,
    required this.onSave,
  });

  @override
  State<_EditProfileFormSheet> createState() => _EditProfileFormSheetState();
}

class _EditProfileFormSheetState extends State<_EditProfileFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _avatarUrlController.text = widget.initialAvatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _nameController.text,
        _passwordController.text,
        _avatarUrlController.text,
      );
    } catch (_) {
      // Error ditangani oleh provider / UI induk
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar
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
                'Edit Profil Pengguna',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // Nama Lengkap
              Text(
                'Nama Lengkap',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  if (v.trim().length < 3) {
                    return 'Nama terlalu pendek';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Baru (Opsional)
              Text(
                'Password Baru (Opsional)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Biarkan kosong jika tidak diubah',
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // URL Avatar (Opsional)
              Text(
                'URL Foto Profil / Avatar (Opsional)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _avatarUrlController,
                style: GoogleFonts.poppins(fontSize: 14),
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'Contoh: https://example.com/avatar.png',
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  prefixIcon: const Icon(Icons.link_rounded, size: 20),
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final uri = Uri.tryParse(v.trim());
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Format URL tidak valid';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.indigo500.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan Perubahan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

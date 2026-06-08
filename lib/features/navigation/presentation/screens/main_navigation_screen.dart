import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:task_management/core/themes/app_colors.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../tasks/presentation/widgets/task_tab_body.dart';
import '../../../tasks/presentation/widgets/categories_tab_body.dart';
import '../../../tasks/providers/task_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      context.read<TaskProvider>().fetchTasks(authToken: auth.token);
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(isMenuMode: true),
    const TasksTabBody(),
    const CategoriesTabBody(),
    const SettingsScreen(isMenuMode: true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color dockBgColor = AppColors.slate800.withValues(alpha: 0.9);
    final Color dockBorderColor = AppColors.indigo500.withValues(alpha: 0.25);
    final Color activeCircleColor = AppColors.indigo500;
    final Color inactiveCircleColor = Colors.white.withValues(alpha: 0.06);
    final Color activeIconColor = Colors.white;
    final Color inactiveIconColor = Colors.white.withValues(alpha: 0.45);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // We use a Stack to float the Bottom Navigation Dock on top of our screens
      body: Stack(
        children: [
          // Screen body
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // Floating Navigation Dock
          Positioned(
            bottom: 40, // Jarak bawah 64px
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    // height: 62,
                    decoration: BoxDecoration(
                      color: dockBgColor,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: dockBorderColor,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: HugeIcons.strokeRoundedHome01,
                          label: 'Home',
                          activeCircleColor: activeCircleColor,
                          inactiveCircleColor: inactiveCircleColor,
                          activeIconColor: activeIconColor,
                          inactiveIconColor: inactiveIconColor,
                        ),
                        const SizedBox(width: 8),
                        _buildNavItem(
                          index: 1,
                          icon: HugeIcons.strokeRoundedTask02,
                          label: 'Task',
                          activeCircleColor: activeCircleColor,
                          inactiveCircleColor: inactiveCircleColor,
                          activeIconColor: activeIconColor,
                          inactiveIconColor: inactiveIconColor,
                        ),
                        const SizedBox(width: 8),
                        _buildNavItem(
                          index: 2,
                          icon: HugeIcons.strokeRoundedDashboardSquare01,
                          label: 'Kategori',
                          activeCircleColor: activeCircleColor,
                          inactiveCircleColor: inactiveCircleColor,
                          activeIconColor: activeIconColor,
                          inactiveIconColor: inactiveIconColor,
                        ),
                        const SizedBox(width: 8),
                        _buildNavItem(
                          index: 3,
                          icon: HugeIcons.strokeRoundedUserCircle,
                          label: 'Akun',
                          activeCircleColor: activeCircleColor,
                          inactiveCircleColor: inactiveCircleColor,
                          activeIconColor: activeIconColor,
                          inactiveIconColor: inactiveIconColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required List<List<dynamic>> icon,
    required String label,
    required Color activeCircleColor,
    required Color inactiveCircleColor,
    required Color activeIconColor,
    required Color inactiveIconColor,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? activeCircleColor : inactiveCircleColor,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.0,
                )
              : null,
        ),
        child: Center(
          child: HugeIcon(
            icon: icon,
            size: 24,
            color: isSelected ? activeIconColor : inactiveIconColor,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/routes/app_router.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/tasks/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const _AppRoot(),
    );
  }
}

/// [_AppRoot] selalu merender [MaterialApp.router] — tidak ada conditional switching.
/// GoRouter mengelola splash screen sebagai route tersendiri.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = AppRouter.createRouter(authProvider);

    // Gunakan Future.microtask agar initialize() berjalan setelah
    // seluruh widget tree selesai di-build, mencegah '!_dirty' assertion.
    Future.microtask(() => authProvider.initialize());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Task Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

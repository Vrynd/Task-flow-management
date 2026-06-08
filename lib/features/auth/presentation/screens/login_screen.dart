import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_footer_link.dart';

/// Halaman Login dengan desain split-layout premium.
///
/// Struktur:
/// ┌────────────────────────┐
/// │   Hero Panel (atas)    │  ← Gradient + branding
/// ├────────────────────────┤
/// │   Form Panel (bawah)   │  ← Input fields + actions
/// └────────────────────────┘
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.indigo600,
      body: Column(
        children: [
          // ── Hero Panel ────────────────────────────────────────
          _HeroPanel(height: size.height * 0.38),

          // ── Form Panel ────────────────────────────────────────
          Expanded(
            child: _FormPanel(
              child: const _LoginFormContent(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Panel ──────────────────────────────────────────────────────────────

class _HeroPanel extends StatelessWidget {
  final double height;

  const _HeroPanel({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // ── Gradient Background ────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4338CA), AppColors.indigo600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Dekorasi lingkaran blur ────────────────────────────
          Positioned(
            top: -40,
            right: -40,
            child: _DecorCircle(size: 180, opacity: 0.08),
          ),
          Positioned(
            top: 60,
            right: 40,
            child: _DecorCircle(size: 80, opacity: 0.12),
          ),
          Positioned(
            bottom: 20,
            left: -20,
            child: _DecorCircle(size: 120, opacity: 0.07),
          ),

          // ── Content ────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Selamat\nDatang Kembali 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Masuk dan lanjutkan produktivitas Anda',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form Panel ──────────────────────────────────────────────────────────────

class _FormPanel extends StatelessWidget {
  final Widget child;

  const _FormPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        child: child,
      ),
    );
  }
}

// ─── Login Form Content ───────────────────────────────────────────────────────

class _LoginFormContent extends StatefulWidget {
  const _LoginFormContent();

  @override
  State<_LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends State<_LoginFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.rememberedEmail != null && auth.rememberedEmail!.isNotEmpty) {
      _emailController.text = auth.rememberedEmail!;
      _rememberMe = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await context.read<AuthProvider>().login(
          email: _emailController.text,
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );

    if (success && context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Label ───────────────────────────────────
              Text(
                'Masuk ke Akun',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Isi detail akun Anda di bawah ini',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 24),

              // ── Error Banner ────────────────────────────────────
              if (auth.errorMessage != null) ...[
                AuthErrorBanner(message: auth.errorMessage!),
                const SizedBox(height: 16),
              ],

              // ── Email ────────────────────────────────────────────
              AuthTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: 'Email',
                hint: 'nama@email.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ── Password ─────────────────────────────────────────
              AuthTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: 'Password',
                hint: 'Masukkan password Anda',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onEditingComplete: () => _submit(context),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  if (v.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ── Remember Me + Lupa Password ─────────────────────
              Row(
                children: [
                  _SmallCheckbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    label: 'Ingat saya 7 hari',
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {}, //
                    child: Text(
                      'Lupa password?',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.indigo500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Login Button ─────────────────────────────────────
              AuthButton(
                label: 'Masuk',
                isLoading: auth.isLoading,
                onPressed: () => _submit(context),
              ),

              const SizedBox(height: 28),

              // ── Divider ──────────────────────────────────────────
              const AuthDividerOr(),

              const SizedBox(height: 24),

              // ── Register Link ────────────────────────────────────
              AuthFooterLink(
                prefixText: 'Belum punya akun?',
                linkText: 'Daftar sekarang',
                onTap: () => context.go('/register'),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ─── Small Checkbox Row ───────────────────────────────────────────────────────

class _SmallCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;

  const _SmallCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.indigo600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dekorasi Lingkaran ───────────────────────────────────────────────────────

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_footer_link.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      body: Column(
        children: [
          _HeroPanel(height: size.height * 0.30),

          Expanded(
            child: _FormPanel(
              child: const _RegisterFormContent(),
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
                colors: [Color(0xFF3730A3), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Dekorasi ──────────────────────────────────────────
          Positioned(
            top: -30,
            left: -30,
            child: _DecorCircle(size: 160, opacity: 0.08),
          ),
          Positioned(
            bottom: -10,
            right: 20,
            child: _DecorCircle(size: 100, opacity: 0.1),
          ),
          Positioned(
            top: 30,
            right: -20,
            child: _DecorCircle(size: 80, opacity: 0.06),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Buat Akun Baru ✨',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Daftar gratis dan mulai kelola tugas Anda',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.75),
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
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        child: child,
      ),
    );
  }
}

// ─── Register Form Content ────────────────────────────────────────────────────

class _RegisterFormContent extends StatefulWidget {
  const _RegisterFormContent();

  @override
  State<_RegisterFormContent> createState() => _RegisterFormContentState();
}

class _RegisterFormContentState extends State<_RegisterFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await context.read<AuthProvider>().register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
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
              // ── Section Header ──────────────────────────────────
              Text(
                'Informasi Akun',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lengkapi data diri Anda untuk mendaftar',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              // ── Error Banner ────────────────────────────────────
              if (auth.errorMessage != null) ...[
                AuthErrorBanner(message: auth.errorMessage!),
                const SizedBox(height: 16),
              ],

              // ── Nama Lengkap ─────────────────────────────────────
              _FieldLabel(label: 'Nama Lengkap'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _nameController,
                focusNode: _nameFocus,
                label: '',
                hint: 'Masukkan nama lengkap Anda',
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_emailFocus),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama lengkap wajib diisi';
                  }
                  if (v.trim().length < 2) return 'Nama terlalu pendek';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ── Email ─────────────────────────────────────────────
              _FieldLabel(label: 'Alamat Email'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: '',
                hint: 'nama@email.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(v.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ── Password ──────────────────────────────────────────
              _FieldLabel(label: 'Password'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: '',
                hint: 'Minimal 6 karakter',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_confirmFocus),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  if (v.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ── Konfirmasi Password ───────────────────────────────
              _FieldLabel(label: 'Konfirmasi Password'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _confirmPasswordController,
                focusNode: _confirmFocus,
                label: '',
                hint: 'Ulangi password Anda',
                prefixIcon: Icons.lock_reset_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onEditingComplete: () => _submit(context),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Konfirmasi password wajib diisi';
                  }
                  if (v != _passwordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // ── Submit Button ─────────────────────────────────────
              AuthButton(
                label: 'Buat Akun',
                isLoading: auth.isLoading,
                onPressed: () => _submit(context),
              ),

              const SizedBox(height: 24),

              // ── Divider ───────────────────────────────────────────
              const AuthDividerOr(),

              const SizedBox(height: 20),

              // ── Login Link ────────────────────────────────────────
              AuthFooterLink(
                prefixText: 'Sudah punya akun?',
                linkText: 'Masuk di sini',
                onTap: () => context.go('/login'),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ─── Field Label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
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

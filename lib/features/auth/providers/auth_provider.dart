import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/api_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// ─── Auth State ─────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// ─── Shared Preferences Keys ─────────────────────────────────────────────────

class _PrefKeys {
  static const String token = 'auth_token';
  static const String tokenExpiry = 'auth_token_expiry';
  static const String userId = 'auth_user_id';
  static const String userName = 'auth_user_name';
  static const String userEmail = 'auth_user_email';
  static const String userAvatarUrl = 'auth_user_avatar_url';
}

/// [AuthProvider] mengelola state autentikasi di seluruh aplikasi.
///
/// Tidak boleh import widget atau screen apapun.
/// Menggunakan [AuthService] untuk API calls dan [SharedPreferences]
/// untuk persistensi sesi (fitur "Ingat Saya" 7 hari).
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ─── State ──────────────────────────────────────────────────────────────

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _token;
  String? _errorMessage;
  bool _isLoading = false;

  // ─── Getters ─────────────────────────────────────────────────────────────

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _token != null;

  // ─── Initialization ───────────────────────────────────────────────────────

  /// Dipanggil saat app pertama kali dibuka.
  /// Cek apakah ada sesi yang masih valid (Remember Me).
  Future<void> initialize() async {
    // Set langsung tanpa notifyListeners() untuk menghindari
    // trigger rebuild saat widget tree belum selesai dibuat.
    _isLoading = true;
    _status = AuthStatus.initial;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_PrefKeys.token);
      final expiryStr = prefs.getString(_PrefKeys.tokenExpiry);

      if (savedToken != null && expiryStr != null) {
        final expiry = DateTime.tryParse(expiryStr);

        if (expiry != null && expiry.isAfter(DateTime.now())) {
          // Sesi masih valid, restore user dari prefs
          _token = savedToken;
          _currentUser = _restoreUserFromPrefs(prefs);
          _status = AuthStatus.authenticated;
        } else {
          // Sesi kadaluarsa, hapus data
          await _clearSession(prefs);
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      // Notify hanya SEKALI di akhir setelah semua state siap
      notifyListeners();
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  /// Mendaftarkan user baru.
  ///
  /// - [rememberMe]: Jika true, token disimpan selama 7 hari.
  ///
  /// Return `true` jika berhasil, `false` jika gagal.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _clearError();
    _setLoading(true);

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (response.isSuccess) {
        _token = response.token;
        _currentUser = response.user;
        _status = AuthStatus.authenticated;

        if (rememberMe) {
          await _saveSession(token: response.token!, user: response.user!);
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message.isNotEmpty
            ? response.message
            : 'Registrasi gagal. Silakan coba lagi.');
        return false;
      }
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Login user.
  ///
  /// - [rememberMe]: Jika true, token disimpan selama 7 hari.
  ///
  /// Return `true` jika berhasil, `false` jika gagal.
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _clearError();
    _setLoading(true);

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.isSuccess) {
        _token = response.token;
        _currentUser = response.user;
        _status = AuthStatus.authenticated;

        if (rememberMe) {
          await _saveSession(token: response.token!, user: response.user!);
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message.isNotEmpty
            ? response.message
            : 'Login gagal. Periksa email dan password Anda.');
        return false;
      }
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  /// Logout user dan hapus semua sesi tersimpan.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);

    _token = null;
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;

    notifyListeners();
  }

  // ─── Session Persistence ──────────────────────────────────────────────────

  Future<void> _saveSession({
    required String token,
    required UserModel user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(days: 7));

    await prefs.setString(_PrefKeys.token, token);
    await prefs.setString(_PrefKeys.tokenExpiry, expiry.toIso8601String());
    await prefs.setString(_PrefKeys.userId, user.id);
    await prefs.setString(_PrefKeys.userName, user.name);
    await prefs.setString(_PrefKeys.userEmail, user.email);
    if (user.avatarUrl != null) {
      await prefs.setString(_PrefKeys.userAvatarUrl, user.avatarUrl!);
    }
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    await prefs.remove(_PrefKeys.token);
    await prefs.remove(_PrefKeys.tokenExpiry);
    await prefs.remove(_PrefKeys.userId);
    await prefs.remove(_PrefKeys.userName);
    await prefs.remove(_PrefKeys.userEmail);
    await prefs.remove(_PrefKeys.userAvatarUrl);
  }

  UserModel _restoreUserFromPrefs(SharedPreferences prefs) {
    return UserModel(
      id: prefs.getString(_PrefKeys.userId) ?? '',
      name: prefs.getString(_PrefKeys.userName) ?? '',
      email: prefs.getString(_PrefKeys.userEmail) ?? '',
      avatarUrl: prefs.getString(_PrefKeys.userAvatarUrl),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Hapus pesan error secara manual (misalnya saat user mulai mengetik).
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}

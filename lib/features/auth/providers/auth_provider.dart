import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/api_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// Shared Preferences
class _PrefKeys {
  static const String token = 'auth_token';
  static const String tokenExpiry = 'auth_token_expiry';
  static const String userId = 'auth_user_id';
  static const String userName = 'auth_user_name';
  static const String userEmail = 'auth_user_email';
  static const String userAvatarUrl = 'auth_user_avatar_url';
}
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();


  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _token;
  String? _errorMessage;
  bool _isLoading = false;
  String? _rememberedEmail;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _token != null;
  String? get rememberedEmail => _rememberedEmail;

  // ─── Initialization ───────────────────────────────────────────────────────

  Future<void> initialize() async {
    _isLoading = true;
    _status = AuthStatus.initial;

    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberedEmail = prefs.getString('remembered_email');
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
      notifyListeners();
    }
  }

  /// Mendaftarkan user baru.
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

        final prefs = await SharedPreferences.getInstance();
        if (rememberMe) {
          await _saveSession(token: response.token!, user: response.user!);
          await prefs.setString('remembered_email', email);
          _rememberedEmail = email;
        } else {
          await prefs.remove('remembered_email');
          _rememberedEmail = null;
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
        rememberMe: rememberMe,
      );

      if (response.isSuccess) {
        _token = response.token;
        _currentUser = response.user;
        _status = AuthStatus.authenticated;

        final prefs = await SharedPreferences.getInstance();
        if (rememberMe) {
          await _saveSession(token: response.token!, user: response.user!);
          await prefs.setString('remembered_email', email);
          _rememberedEmail = email;
        } else {
          await prefs.remove('remembered_email');
          _rememberedEmail = null;
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

  /// Logout user dan hapus semua sesi tersimpan.
  Future<void> logout() async {
    final token = _token;
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);

    _token = null;
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;

    notifyListeners();
    if (token != null) {
      _authService.logout(authToken: token).catchError((_) {
        
      });
    }
  }

  /// Memperbarui user saat ini secara dinamis dan menyinkronkan ke cache lokal.
  void updateCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      final savedToken = prefs.getString(_PrefKeys.token);
      if (savedToken != null) {
        _saveSession(token: savedToken, user: user);
      }
    });
  }

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

import '../../../../core/services/api_service.dart';
import '../models/auth_response.dart';

/// [AuthService] menangani semua API call yang berkaitan dengan autentikasi.
///
/// Bergantung pada [ApiService] sebagai HTTP client.
/// Tidak boleh import widget atau screen apapun.
class AuthService {
  final ApiService _api;

  AuthService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  // ─── Endpoints ───────────────────────────────────────────────────────────

  static const String _registerEndpoint = '/api/auth/register';
  static const String _loginEndpoint = '/api/auth/login';

  // ─── Register ────────────────────────────────────────────────────────────

  /// Mendaftarkan user baru ke server.
  ///
  /// - [name]: Nama lengkap user
  /// - [email]: Email user
  /// - [password]: Password minimal 6 karakter
  /// - [avatarUrl]: URL avatar opsional
  ///
  /// Melempar [ApiException] jika terjadi error pada server atau jaringan.
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      body['avatar_url'] = avatarUrl;
    }

    final response = await _api.post(_registerEndpoint, body: body);
    return AuthResponse.fromJson(response);
  }

  // ─── Login ───────────────────────────────────────────────────────────────

  /// Login user ke server.
  ///
  /// - [email]: Email user
  /// - [password]: Password user
  ///
  /// Melempar [ApiException] jika terjadi error pada server atau jaringan.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final body = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    final response = await _api.post(_loginEndpoint, body: body);
    return AuthResponse.fromJson(response);
  }
}

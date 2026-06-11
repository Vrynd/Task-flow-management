import '../../../../core/services/api_service.dart';
import '../models/auth_response.dart';

class AuthService {
  final ApiService _api;

  AuthService({ApiService? apiService})
      : _api = apiService ?? ApiService();


  static const String _registerEndpoint = '/api/auth/register';
  static const String _loginEndpoint = '/api/auth/login';
  static const String _logoutEndpoint = '/api/auth/logout';

  // Register
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

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final body = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
      'remember_me': rememberMe,
    };

    final response = await _api.post(_loginEndpoint, body: body);
    return AuthResponse.fromJson(response);
  }

  // Logout
  Future<void> logout({required String authToken}) async {
    await _api.post(_logoutEndpoint, body: {}, authToken: authToken);
  }
}

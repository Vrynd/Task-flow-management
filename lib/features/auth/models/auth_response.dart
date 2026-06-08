import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;

  const AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final userJson = data?['user'] as Map<String, dynamic>?;

    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      user: userJson != null ? UserModel.fromJson(userJson) : null,
      token: data?['token'] as String?,
    );
  }

  bool get isSuccess => success && user != null && token != null;

  @override
  String toString() =>
      'AuthResponse(success: $success, message: $message, user: $user)';
}

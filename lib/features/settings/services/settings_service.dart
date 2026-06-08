import 'package:task_management/core/services/api_service.dart';
import 'package:task_management/features/auth/models/user_model.dart';
import 'package:task_management/features/settings/models/user_activity_model.dart';
import 'package:task_management/features/settings/models/user_statistics_model.dart';

class SettingsService {
  final ApiService _api;

  SettingsService({ApiService? apiService}) : _api = apiService ?? ApiService();

  static const String _profileEndpoint = '/api/users/profile';
  static const String _statisticsEndpoint = '/api/users/statistics';
  static const String _activitiesEndpoint = '/api/users/activities';

  /// Mengambil profil pengguna terbaru
  Future<UserModel> getProfile({String? authToken}) async {
    final response = await _api.get(_profileEndpoint, authToken: authToken);

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException(message: 'Format respons profil tidak valid');
    }

    return UserModel.fromJson(data);
  }

  /// Memperbarui data profil pengguna
  Future<UserModel> updateProfile({
    required String name,
    String? password,
    String? avatarUrl,
    String? authToken,
  }) async {
    final body = <String, dynamic>{'name': name.trim()};

    if (password != null && password.trim().isNotEmpty) {
      body['password'] = password;
    }

    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      body['avatar_url'] = avatarUrl.trim();
    }

    final response = await _api.put(
      _profileEndpoint,
      body: body,
      authToken: authToken,
    );

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException(
        message: 'Format respons update profil tidak valid',
      );
    }

    return UserModel.fromJson(data);
  }

  /// Mengambil data statistik tugas pengguna
  Future<UserStatisticsModel> getStatistics({String? authToken}) async {
    final response = await _api.get(_statisticsEndpoint, authToken: authToken);

    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException(message: 'Format respons statistik tidak valid');
    }

    return UserStatisticsModel.fromJson(data);
  }

  /// Mengambil daftar riwayat aktivitas pengguna.
  Future<List<UserActivityModel>> getActivities({String? authToken}) async {
    final response = await _api.get(_activitiesEndpoint, authToken: authToken);

    final rawList = response['data'];
    if (rawList == null) return [];

    if (rawList is List) {
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(UserActivityModel.fromJson)
          .toList();
    }
    return [];
  }
}

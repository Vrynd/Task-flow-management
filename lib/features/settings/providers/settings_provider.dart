import 'package:flutter/foundation.dart';
import 'package:task_management/core/services/api_service.dart';
import 'package:task_management/features/auth/models/user_model.dart';
import 'package:task_management/features/auth/providers/auth_provider.dart';
import 'package:task_management/features/settings/models/user_activity_model.dart';
import 'package:task_management/features/settings/models/user_statistics_model.dart';
import 'package:task_management/features/settings/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  SettingsProvider({SettingsService? settingsService})
    : _service = settingsService ?? SettingsService();

  //
  UserModel? _profile;
  UserStatisticsModel? _statistics;
  List<UserActivityModel> _activities = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  //
  UserModel? get profile => _profile;
  UserStatisticsModel? get statistics => _statistics;
  List<UserActivityModel> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  // Mengambil data profil, statistik, dan log aktivitas pengguna
  Future<void> fetchSettingsData({
    String? authToken,
    AuthProvider? authProvider,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getProfile(authToken: authToken),
        _service.getStatistics(authToken: authToken),
        _service.getActivities(authToken: authToken),
      ]);

      _profile = results[0] as UserModel;
      _statistics = results[1] as UserStatisticsModel;
      _activities = results[2] as List<UserActivityModel>;

      // Sinkronkan ke authProvider jika tersedia
      if (authProvider != null && _profile != null) {
        authProvider.updateCurrentUser(_profile!);
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Gagal memuat data profil dan statistik.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengirim pembaruan profil pengguna
  Future<bool> updateProfile({
    required String name,
    String? password,
    String? avatarUrl,
    String? authToken,
    required AuthProvider authProvider,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _service.updateProfile(
        name: name,
        password: password,
        avatarUrl: avatarUrl,
        authToken: authToken,
      );

      _profile = updatedUser;

      // Update data user secara global di AuthProvider
      authProvider.updateCurrentUser(updatedUser);

      // Refresh log aktivitas & statistik terbaru
      try {
        final results = await Future.wait([
          _service.getStatistics(authToken: authToken),
          _service.getActivities(authToken: authToken),
        ]);
        _statistics = results[0] as UserStatisticsModel;
        _activities = results[1] as List<UserActivityModel>;
      } catch (_) {
        // Abaikan jika refresh statistik gagal agar tidak menggagalkan status sukses profil
      }

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui data profil.';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Membersihkan eror
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

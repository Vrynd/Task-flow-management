import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  static const String baseUrl = 'http://192.168.100.63:3000';
  static const Duration _timeout = Duration(seconds: 15);
  final http.Client _client = http.Client();

  Map<String, String> _buildHeaders({String? authToken}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  // ─── POST ────────────────────────────────────────────────────────────────────

  /// Mengirim POST request ke [endpoint] dengan [body].
  ///
  /// - [endpoint]: Path setelah base URL, contoh: `/api/auth/register`
  /// - [body]: Map yang akan di-encode ke JSON
  /// - [authToken]: Opsional, Bearer token untuk protected endpoint
  ///
  /// Melempar [ApiException] jika terjadi error.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(authToken: authToken),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on HttpException {
      throw const ApiException(message: 'Terjadi kesalahan pada koneksi HTTP.');
    } on FormatException {
      throw const ApiException(message: 'Format respons dari server tidak valid.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Terjadi kesalahan tidak terduga: $e');
    }
  }

  // ─── GET ─────────────────────────────────────────────────────────────────────

  /// Mengirim GET request ke [endpoint].
  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? authToken,
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(authToken: authToken))
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Terjadi kesalahan tidak terduga: $e');
    }
  }

  // ─── PUT ─────────────────────────────────────────────────────────────────────

  /// Mengirim PUT request ke [endpoint] dengan [body].
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await _client
          .put(
            uri,
            headers: _buildHeaders(authToken: authToken),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on HttpException {
      throw const ApiException(message: 'Terjadi kesalahan pada koneksi HTTP.');
    } on FormatException {
      throw const ApiException(message: 'Format respons dari server tidak valid.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Terjadi kesalahan tidak terduga: $e');
    }
  }

  // ─── DELETE ──────────────────────────────────────────────────────────────────

  /// Mengirim DELETE request ke [endpoint].
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? authToken,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await _client
          .delete(uri, headers: _buildHeaders(authToken: authToken))
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on HttpException {
      throw const ApiException(message: 'Terjadi kesalahan pada koneksi HTTP.');
    } on FormatException {
      throw const ApiException(message: 'Format respons dari server tidak valid.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Terjadi kesalahan tidak terduga: $e');
    }
  }

  // ─── Response Handler ────────────────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    // Ambil pesan error dari body jika ada
    final errorMessage = decoded['message'] as String? ??
        decoded['error'] as String? ??
        'Terjadi kesalahan pada server (${response.statusCode}).';

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } catch (_) {
      return {'raw': body};
    }
  }
}

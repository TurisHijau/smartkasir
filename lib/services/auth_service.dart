import 'dart:convert';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/services/api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  /// Login and store the JWT token.
  /// Returns the token string on success.
  Future<String?> login(String username, String password) async {
    final response = await _api.post(
      '/auth/login',
      body: {"username": username, "password": password},
      auth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"] as String?;
      if (token != null) {
        await _api.setToken(token);
      }
      return token;
    } else {
      final body = response.body;
      throw Exception("Login gagal: ${response.statusCode} - $body");
    }
  }

  /// Register a new user and store.
  Future<User> register(RegisterRequest request) async {
    final response = await _api.post(
      '/auth/register',
      body: request.toJson(),
      auth: false,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      final body = response.body;
      throw Exception("Registrasi gagal: ${response.statusCode} - $body");
    }
  }

  /// Get current user profile and store
  Future<AuthResponse> getProfile() async {
    final response = await _api.get('/auth/me');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      final body = response.body;
      throw Exception("Gagal mendapatkan profil: ${response.statusCode} - $body");
    }
  }

  /// Clear the stored token.
  Future<void> logout() async {
    await _api.clearToken();
  }
}

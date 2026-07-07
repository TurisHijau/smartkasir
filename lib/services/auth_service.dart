import 'dart:convert';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/models/store.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/services/api_client.dart';
import 'package:smartkasir/exceptions/auth_exception.dart';

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
      try {
        final body = jsonDecode(response.body);
        final msg = body["message"] as String?;
        if (response.statusCode == 401) {
          throw Exception("Username atau password salah");
        }
        throw Exception(msg ?? "Login gagal, coba lagi");
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception("Login gagal, coba lagi");
      }
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
    } else if (response.statusCode == 401) {
      // Session expired - clear token and throw UnauthorizedException
      await logout();
      throw UnauthorizedException(
        "Sesi login sudah habis. Silahkan login kembali.",
      );
    } else {
      final body = response.body;
      throw Exception(
        "Gagal mendapatkan profil: ${response.statusCode} - $body",
      );
    }
  }

  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    final response = await _api.put('/users/$id', body: data);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromJson(responseData);
    } else {
      throw Exception(
        "Gagal update profil: ${response.statusCode} - ${response.body}",
      );
    }
  }

  Future<Store> updateStore(String id, Map<String, dynamic> data) async {
    final response = await _api.put('/stores/$id', body: data);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Store.fromJson(responseData);
    } else {
      throw Exception(
        "Gagal update toko: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// Clear the stored token.
  Future<void> logout() async {
    await _api.clearToken();
  }
}

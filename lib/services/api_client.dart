import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized API client that handles JWT token management
/// and provides typed HTTP helpers for all API calls.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String baseUrl = "https://smartkasir-api.erzet.site";
  static const String _tokenKey = "smartkasir_prefs/authToken";
  static const String productBaseUrl =
      "https://world.openfoodfacts.org/api/v0/product";

  String? _cachedToken;

  // ── Token management ──────────────────────────────────────────────────────

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  Future<void> setToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get hasToken => _cachedToken != null;

  // ── HTTP headers ──────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  // ── HTTP methods ──────────────────────────────────────────────────────────

  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      "$baseUrl$path",
    ).replace(queryParameters: queryParams);
    print("[API] GET $uri");
    final response = await http.get(uri, headers: await _headers());
    _logResponse(response);
    return response;
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse("$baseUrl$path");
    print("[API] POST $uri");
    final response = await http.post(
      uri,
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    _logResponse(response);
    return response;
  }

  Future<http.Response> put(String path, {Object? body}) async {
    final uri = Uri.parse("$baseUrl$path");
    print("[API] PUT $uri");
    final response = await http.put(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    _logResponse(response);
    return response;
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse("$baseUrl$path");
    print("[API] DELETE $uri");
    final response = await http.delete(uri, headers: await _headers());
    _logResponse(response);
    return response;
  }

  Future<http.Response> getNameByBarcode(
    String barcode, {
    bool auth = false,
  }) async {
    final uri = Uri.parse("$productBaseUrl/$barcode.json");
    print("[API] GET $uri");
    final response = await http.get(uri, headers: await _headers(auth: auth));
    _logResponse(response);
    return response;
  }

  // ── Logging ───────────────────────────────────────────────────────────────

  void _logResponse(http.Response response) {
    print(
      "[API] ${response.statusCode} ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}",
    );
  }
}

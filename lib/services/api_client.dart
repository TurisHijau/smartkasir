import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartkasir/services/app_navigator.dart';
import 'package:smartkasir/views/auth/login_view.dart';

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
    _logRequest("GET", uri);
    final response = await http.get(uri, headers: await _headers());
    return _handleResponse(response);
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse("$baseUrl$path");
    _logRequest("POST", uri);
    final response = await http.post(
      uri,
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    // Login/register are unauthenticated; a 401 there is a credential error,
    // not an expired session, so don't trigger the global logout redirect.
    return _handleResponse(response, redirectOnUnauthorized: auth);
  }

  Future<http.Response> put(String path, {Object? body}) async {
    final uri = Uri.parse("$baseUrl$path");
    _logRequest("PUT", uri);
    final response = await http.put(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse("$baseUrl$path");
    _logRequest("DELETE", uri);
    final response = await http.delete(uri, headers: await _headers());
    return _handleResponse(response);
  }

  Future<http.Response> getNameByBarcode(
    String barcode, {
    bool auth = false,
  }) async {
    final uri = Uri.parse("$productBaseUrl/$barcode.json");
    _logRequest("GET", uri);
    final response = await http.get(uri, headers: await _headers(auth: auth));
    // External OpenFoodFacts call — never tied to our session.
    return _handleResponse(response, redirectOnUnauthorized: false);
  }

  // ── Response handling ──────────────────────────────────────────────────────

  /// Logs the response and, when [redirectOnUnauthorized] is set, intercepts
  /// HTTP 401 to clear the dead token and send the user back to login from
  /// wherever they are. This keeps expired-session handling in one place so an
  /// expired token mid-session no longer leaves the user stranded.
  http.Response _handleResponse(
    http.Response response, {
    bool redirectOnUnauthorized = true,
  }) {
    _logResponse(response);
    if (redirectOnUnauthorized && response.statusCode == 401) {
      _onUnauthorized();
    }
    return response;
  }

  bool _redirectingToLogin = false;

  void _onUnauthorized() {
    // Guard against a burst of concurrent 401s (e.g. several list calls firing
    // at once) all trying to push login.
    if (_redirectingToLogin) return;
    _redirectingToLogin = true;

    clearToken();

    final navigator = appNavigatorKey.currentState;
    if (navigator != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    }

    appMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text("Sesi Anda telah berakhir. Silakan login kembali."),
          backgroundColor: Color.fromARGB(255, 222, 17, 2),
        ),
      );

    // Allow future redirects once this one has been dispatched.
    Future.microtask(() => _redirectingToLogin = false);
  }

  // ── Logging ───────────────────────────────────────────────────────────────

  void _logRequest(String method, Uri uri) {
    if (!kDebugMode) return;
    debugPrint("[API] $method $uri");
  }

  void _logResponse(http.Response response) {
    if (!kDebugMode) return;
    final body = response.body.length > 500
        ? '${response.body.substring(0, 500)}...'
        : response.body;
    debugPrint("[API] ${response.statusCode} $body");
  }
}

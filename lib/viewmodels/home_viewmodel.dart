import 'package:flutter/material.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/views/auth/login_view.dart';
import 'package:smartkasir/views/auth/register_view.dart';
import 'package:smartkasir/services/api_client.dart';
import 'package:smartkasir/views/scanner_view.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel();

  final AuthService _authService = AuthService();

  Future<void> checkAuth(BuildContext context) async {
    final token = await ApiClient().getToken();
    if (token == null) return;

    // A token exists locally, but it may be expired/invalid (e.g. older than
    // a day). Validate it against the backend before entering the app —
    // otherwise the user lands on the dashboard with a dead token and can't
    // reach settings or log out. If validation fails, drop the token and
    // send the user to the login screen.
    try {
      await _authService.getProfile();
    } catch (_) {
      await _authService.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ScannerView()),
        (route) => false,
      );
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  void navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterView()),
    );
  }
}

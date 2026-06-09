import 'package:flutter/material.dart';
import 'package:smartkasir/views/auth/login_view.dart';
import 'package:smartkasir/views/auth/register_view.dart';
import 'package:smartkasir/services/api_client.dart';
import 'package:smartkasir/views/scanner_view.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel();

  Future<void> checkAuth(BuildContext context) async {
    final token = await ApiClient().getToken();
    if (token != null && context.mounted) {
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

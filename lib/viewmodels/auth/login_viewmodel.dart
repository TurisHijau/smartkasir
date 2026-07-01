import 'package:flutter/material.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/views/auth/register_view.dart';
import 'package:smartkasir/views/scanner_view.dart';

class LoginViewmodel extends ChangeNotifier {
  final AuthService authService = AuthService();

  bool loading = false;
  String? errorMessage;
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      errorMessage = "Username dan password tidak boleh kosong";
      notifyListeners();
      return;
    }

    try {
      loading = true;
      errorMessage = null;
      notifyListeners();

      final token = await authService.login(username, password);

      if (token != null && context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ScannerView()),
          (route) => false,
        );
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage ?? "Login gagal",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterView()),
    );
  }
}

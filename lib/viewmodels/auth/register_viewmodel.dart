import 'package:flutter/material.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/views/auth/login_view.dart';

class RegisterViewmodel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storeAddressController = TextEditingController();
  final TextEditingController storePhoneController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<bool> register() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      errorMessage = "Password dan Konfirmasi Password tidak cocok";
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final request = RegisterRequest(
        businessName: storeNameController.text.trim(),
        storeAddress: storeAddressController.text.trim(),
        storePhone: storePhoneController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        username: usernameController.text.trim(),
        password: password,
        email: emailController.text.trim(),
        ownerPhone: ownerPhoneController.text.trim(),
      );

      await _authService.register(request);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginView(),
      ),
    );
  }

  @override
  void dispose() {
    ownerNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    ownerPhoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    storeNameController.dispose();
    storeAddressController.dispose();
    storePhoneController.dispose();
    super.dispose();
  }
}
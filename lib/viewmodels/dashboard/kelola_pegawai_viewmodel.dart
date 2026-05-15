import 'package:flutter/material.dart';

class KelolaPegawaiViewModel extends ChangeNotifier {
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

  void addEmployee() {
    // TODO: Implement employee addition logic
    notifyListeners();
  }
}

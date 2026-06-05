import 'package:flutter/material.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/services/user_service.dart';

class KelolaPegawaiViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  String? errorMessage;

  final User? editingUser;
  Role selectedRole = Role.CASHIER;

  KelolaPegawaiViewModel({this.editingUser}) {
    if (editingUser != null) {
      selectedRole = editingUser!.role;
    }
  }

  bool get isEditMode => editingUser != null;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void setRole(Role role) {
    selectedRole = role;
    notifyListeners();
  }

  Future<bool> saveEmployee({
    required String name,
    required String phone,
    required String username,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final request = UserRequest(
        name: name,
        username: username,
        password: password,
        role: selectedRole,
        phone: phone.isNotEmpty ? phone : null,
      );

      if (isEditMode) {
        await _userService.update(editingUser!.id!, request);
      } else {
        await _userService.create(request);
      }

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

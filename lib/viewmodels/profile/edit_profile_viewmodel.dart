import 'package:flutter/material.dart';
import 'package:smartkasir/services/auth_service.dart';

class EditProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> updateProfile(
    BuildContext context, {
    required String userId,
    required String name,
    required String email,
    required String username,
    required String password,
    required String role,
    required String phone,
  }) async {
    if (name.trim().isEmpty) {
      errorMessage = "Nama toko tidak boleh kosong";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = {
        "name": name.trim(),
        "email": email.trim(),
        "username": username.trim(),
        "role": role,
        "phone": phone.trim(),
      };
      if (password.isNotEmpty) {
        data["password"] = password;
      }

      await _authService.updateUser(userId, data);

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

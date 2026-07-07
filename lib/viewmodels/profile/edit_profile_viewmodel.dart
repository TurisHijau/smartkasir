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
    required String phone,
  }) async {
    if (name.trim().isEmpty) {
      errorMessage = "Nama tidak boleh kosong";
      notifyListeners();
      return false;
    }

    if (username.trim().isEmpty) {
      errorMessage = "Username tidak boleh kosong";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{
        "name": name.trim(),
        "username": username.trim(),
      };

      if (email.trim().isNotEmpty) {
        data["email"] = email.trim();
      }
      if (phone.trim().isNotEmpty) {
        data["phone"] = phone.trim();
      }
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

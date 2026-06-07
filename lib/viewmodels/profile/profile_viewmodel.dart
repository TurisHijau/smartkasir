import 'package:flutter/material.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/services/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthResponse? profileData;
  bool isLoading = false;
  String? errorMessage;

  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      profileData = await _authService.getProfile();

    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void editProfile() {
    // TODO: Implement profile editing logic
    notifyListeners();
  }
}

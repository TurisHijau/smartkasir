import 'package:flutter/material.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/views/profile/edit_profile_view.dart';
import 'package:smartkasir/views/profile/edit_store_view.dart';

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

  void editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileView(profileData: profileData!),
      ),
    ).then((_) => loadProfile());
  }

  void editStore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditStoreView(profileData: profileData!),
      ),
    ).then((_) => loadProfile());
  }
}


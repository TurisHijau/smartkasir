import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel();

  void navigateToLogin(BuildContext context) {
    // TODO: Implement navigation to the login view
    debugPrint("Navigate to Login");
  }

  void navigateToRegister(BuildContext context) {
    // TODO: Implement navigation to the store registration view
    debugPrint("Navigate to Register Store");
  }
}
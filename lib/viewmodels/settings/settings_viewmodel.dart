import 'package:flutter/material.dart';
import 'package:smartkasir/views/settings/settings_view.dart';

class SettingsViewModel extends ChangeNotifier {
  // Placeholder for settings logic
  void navigateToProfile() {
    // TODO: Implement navigation logic
    notifyListeners();
  }

  void navigateToEmployees() {
    // TODO: Implement navigation logic
    notifyListeners();
  }

  void navigateToProducts() {
    // TODO: Implement navigation logic
    notifyListeners();
  }

  void refreshPrinter() {
    // TODO: Implement printer refresh logic
    notifyListeners();
  }

    void navigateToSetting(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SettingsView(),
    ),
  );
}
}


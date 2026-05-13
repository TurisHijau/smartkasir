import 'package:flutter/material.dart';
import 'package:smartkasir/views/scanner_view.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel();

  void navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScannerView()),
    );
  }

  void navigateToRegister(BuildContext context) {
    debugPrint("Navigate to Register Store");
  }
}
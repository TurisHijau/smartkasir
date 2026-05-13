import 'package:flutter/material.dart';
import 'package:smartkasir/views/auth/register_view.dart';
import 'package:smartkasir/views/scanner_view.dart';

class LoginViewmodel extends ChangeNotifier {
  LoginViewmodel();


void navigateToRegister(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const RegisterView(),
    ),
  );
  }
  
void navigateToScannerView(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ScannerView(),
    ),
  );
  }

}
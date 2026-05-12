import 'package:flutter/material.dart';
import 'package:smartkasir/views/auth/login_view.dart';

class RegisterViewmodel extends ChangeNotifier {
  RegisterViewmodel();

  
void navigateToLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginView(),
    ),
  );
  }
}
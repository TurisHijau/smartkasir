import 'package:flutter/material.dart';
import 'package:smartkasir/views/auth/login_view.dart';
import 'package:smartkasir/views/auth/register_view.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel();

  void navigateToLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginView(),
    ),
  );
}

  void navigateToRegister(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const RegisterView(),
    ),
  );
  }
}
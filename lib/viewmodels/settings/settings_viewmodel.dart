import 'package:flutter/material.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/views/analitik_view.dart';
import 'package:smartkasir/views/dashboard/list_pegawai_view.dart';
import 'package:smartkasir/views/dashboard/list_produk_view.dart';
import 'package:smartkasir/views/profile/profile_view.dart';
import 'package:smartkasir/views/saldo_view.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthResponse? profileData;
  bool isLoading = false;
  String? errorMessage;

  SettingsViewModel() {
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

  void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileView()),
    ).then((_) => loadProfile());
  }

  void navigateToAnalitik(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalitikView()),
    );
  }

  void navigateToEmploye(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListPegawaiView()),
    );
  }

  void navigateToProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListProdukView()),
    );
  }

  void navigateToSaldo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SaldoView()),
    );
  }

  void refreshPrinter() {
    // TODO: Implement printer refresh logic
    notifyListeners();
  }

  // NGARAH KE SETTINGAN YA
  void navigateToSetting(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SettingsView(),
    ),
  );
}

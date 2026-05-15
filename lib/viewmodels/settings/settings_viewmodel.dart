import 'package:flutter/material.dart';
import 'package:smartkasir/views/analitik_view.dart';
import 'package:smartkasir/views/dashboard/list_pegawai_view.dart';
import 'package:smartkasir/views/dashboard/list_produk_view.dart';
import 'package:smartkasir/views/profile/profile_view.dart';

class SettingsViewModel extends ChangeNotifier {
  // Placeholder for settings logic
  void navigateToProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ProfileView(),
    ),
  );
}

  void navigateToAnalitik(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AnalitikView(),
    ),
  );
}

  void navigateToEmploye(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ListPegawaiView(),
    ),
  );
}

  void navigateToProducts(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ListProdukView(),
    ),
  );
}

  void refreshPrinter() {
    // TODO: Implement printer refresh logic
    notifyListeners();
  }

    
}


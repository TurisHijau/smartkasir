import 'package:flutter/material.dart';
import 'package:smartkasir/views/tambah_bank_view.dart';

class SaldoViewModel extends ChangeNotifier {
  SaldoViewModel();

  final int saldo = 67067000;

  String get formattedSaldo => 'Rp67.067.000,00';

  final List<Map<String, dynamic>> bankAccounts = [
    {
      "name": "Dandy Pradnyana",
      "number": "BRI - 1296 7679 1736 51",
      "icon": 'assets/images/payment/BRI.png',
    },
    {
      "name": "Dandy Pradnyana",
      "number": "Gopay - 086712367123",
      "icon": 'assets/images/payment/GoPay.png',
    },
  ];

  void navigateToBank(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahBankView(),
      ),
    );
  }
}
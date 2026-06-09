import 'package:flutter/material.dart';

class TambahBankViewModel extends ChangeNotifier {
  TambahBankViewModel();

  final TextEditingController namaAkunController =
      TextEditingController();

  final TextEditingController noRekeningController =
      TextEditingController();

  final List<String> bankList = [
  'AstraPay',
  'Bank Mega',
  'BCA',
  'Blu BCA',
  'BNI',
  'BRI',
  'BTN',
  'CIMB Niaga',
  'DANA',
  'Danamon',
  'GoPay',
  'Jago',
  'LinkAja',
  'Mandiri',
  'Neo Bank',
  'OVO',
  'PayPal',
  'Permata Bank',
  'SeaBank',
  'ShopeePay',
  'Sinarmas',
];

  final Map<String, String> bankImages = {
  'AstraPay': 'assets/images/payment/AstraPay.png',
  'Bank Mega': 'assets/images/payment/BankMega.png',
  'BCA': 'assets/images/payment/BCA.png',
  'Blu BCA': 'assets/images/payment/BluBCA.png',
  'BNI': 'assets/images/payment/BNI.png',
  'BRI': 'assets/images/payment/BRI.png',
  'BTN': 'assets/images/payment/BTN.png',
  'CIMB Niaga': 'assets/images/payment/CIMBNiaga.png',
  'DANA': 'assets/images/payment/DANA.png',
  'Danamon': 'assets/images/payment/Danamon.png',
  'GoPay': 'assets/images/payment/GoPay.png',
  'Jago': 'assets/images/payment/Jago.png',
  'LinkAja': 'assets/images/payment/LinkAja.png',
  'Mandiri': 'assets/images/payment/Mandiri.png',
  'Neo Bank': 'assets/images/payment/NeoBank.png',
  'OVO': 'assets/images/payment/OVO.png',
  'PayPal': 'assets/images/payment/PayPal.png',
  'Permata Bank': 'assets/images/payment/PermataBank.png',
  'SeaBank': 'assets/images/payment/SeaBank.png',
  'ShopeePay': 'assets/images/payment/ShopeePay.png',
  'Sinarmas': 'assets/images/payment/Sinarmas.png',
};

  String selectedBank = 'DANA';

  void changeBank(String value) {
    selectedBank = value;
    notifyListeners();
  }

  @override
  void dispose() {
    namaAkunController.dispose();
    noRekeningController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/views/tambah_bank_view.dart';

class SaldoViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  double _saldo = 0;
  bool _isLoading = true;
  String? _errorMessage;

  double get saldo => _saldo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get formattedSaldo {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(_saldo);
  }

  SaldoViewModel() {
    _loadSaldo();
  }

  Future<void> _loadSaldo() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await _authService.getProfile();
      _saldo = authResponse.user.saldo;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _saldo = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
      MaterialPageRoute(builder: (context) => const TambahBankView()),
    );
  }
}

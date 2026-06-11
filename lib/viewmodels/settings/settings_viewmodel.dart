import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:smartkasir/utils/printer_helper.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/views/dashboard/analitik_view.dart';
import 'package:smartkasir/views/dashboard/list_pegawai_view.dart';
import 'package:smartkasir/views/dashboard/list_produk_view.dart';
import 'package:smartkasir/views/dashboard/transaction_view.dart';
import 'package:smartkasir/views/profile/profile_view.dart';
import 'package:smartkasir/views/saldo_view.dart';
import 'package:smartkasir/views/settings_view.dart';
import 'package:smartkasir/views/auth/login_view.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final PrinterHelper _printerHelper = PrinterHelper();

  AuthResponse? profileData;
  bool isLoading = false;
  String? errorMessage;

  // Printer State
  bool isPrinterConnected = false;
  String? connectedPrinterMac;
  String? connectedPrinterName;
  List<BluetoothInfo> availableBluetoothDevices = [];
  bool isScanningPrinter = false;

  SettingsViewModel() {
    loadProfile();
    loadPrinterState();
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

  void TransactionHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionView(),
      ),
    );
  }

  // PRINTER LOGIC
  Future<void> loadPrinterState() async {
    final prefs = await SharedPreferences.getInstance();
    connectedPrinterMac = prefs.getString('printer_mac');
    connectedPrinterName = prefs.getString('printer_name');
    
    if (connectedPrinterMac != null) {
      await connectPrinter(connectedPrinterMac!, connectedPrinterName ?? 'Unknown');
    }
    notifyListeners();
  }

  Future<void> scanPrinters() async {
    isScanningPrinter = true;
    notifyListeners();
    
    try {
      bool hasPermission = await _printerHelper.checkPermission();
      if (hasPermission) {
        availableBluetoothDevices = await _printerHelper.getBondedDevices();
      } else {
        errorMessage = 'Izin Bluetooth diperlukan';
      }
    } catch (e) {
      errorMessage = 'Gagal memindai perangkat';
    } finally {
      isScanningPrinter = false;
      notifyListeners();
    }
  }

  Future<void> connectPrinter(String mac, String name) async {
    isLoading = true;
    notifyListeners();

    try {
      bool success = await _printerHelper.connect(mac);
      if (success) {
        isPrinterConnected = true;
        connectedPrinterMac = mac;
        connectedPrinterName = name;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('printer_mac', mac);
        await prefs.setString('printer_name', name);
      } else {
        isPrinterConnected = false;
        errorMessage = 'Gagal terhubung ke printer';
      }
    } catch (e) {
      isPrinterConnected = false;
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      await _printerHelper.disconnect();
      isPrinterConnected = false;
      connectedPrinterMac = null;
      connectedPrinterName = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('printer_mac');
      await prefs.remove('printer_name');
      
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  void refreshPrinter() {
    if (connectedPrinterMac != null) {
      connectPrinter(connectedPrinterMac!, connectedPrinterName ?? 'Unknown');
    } else {
      scanPrinters();
    }
  }

  Future<void> testPrint() async {
    if (!isPrinterConnected) return;
    
    await _printerHelper.printStrukBelanja(
      namaToko: profileData?.store.businessName ?? 'TOKO ANDA',
      alamatToko: 'Jl. Contoh No. 123',
      noTelpToko: '08123456789',
      items: [
        {'name': 'Kopi Hitam', 'qty': 2, 'price': 15000, 'total': 30000},
        {'name': 'Roti Bakar', 'qty': 1, 'price': 20000, 'total': 20000},
      ],
      totalSemuanya: 50000,
      uangBayar: 100000,
      kembalian: 50000,
    );
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

  Future<void> logout(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      await _authService.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
        );
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      isLoading = false;
      notifyListeners();
    }
  }
}
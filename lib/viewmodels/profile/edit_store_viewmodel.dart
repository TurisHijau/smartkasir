import 'package:flutter/material.dart';
import 'package:smartkasir/services/auth_service.dart';

class EditStoreViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> updateStore(
    BuildContext context, {
    required String storeId,
    required String businessName,
    required String address,
    required String phone,
  }) async {
    if (businessName.trim().isEmpty) {
      errorMessage = "Nama toko tidak boleh kosong";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{
        "businessName": businessName.trim(),
      };

      if (address.trim().isNotEmpty) {
        data["address"] = address.trim();
      }
      if (phone.trim().isNotEmpty) {
        data["phone"] = phone.trim();
      }

      await _authService.updateStore(storeId, data);

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

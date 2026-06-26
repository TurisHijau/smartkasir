import 'package:flutter/material.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/services/product_service.dart';
import 'package:smartkasir/views/dashboard/barcode_scanner_view.dart';

class KelolaProdukViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  bool isLoading = false;
  bool isCheckingBarcode = false;
  String? errorMessage;
  String? scannedBarcode;
  bool isProductNameLocked = false;

  /// The product being edited, null for create mode.
  final Product? editingProduct;

  KelolaProdukViewModel({this.editingProduct});

  bool get isEditMode => editingProduct != null;

  Future<bool> saveProduct({
    required String barcode,
    required String name,
    required String costPrice,
    required String sellingPrice,
    required String stock,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final product = Product(
        name: name,
        barcode: barcode.isNotEmpty ? barcode : null,
        costPrice: double.tryParse(costPrice) ?? 0,
        sellingPrice: double.tryParse(sellingPrice) ?? 0,
        stock: int.tryParse(stock) ?? 0,
      );

      if (isEditMode) {
        await _productService.update(editingProduct!.id!, product);
      } else {
        await _productService.create(product);
      }

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, String?>> scanProductCode(BuildContext context) async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerView()),
    );

    if (barcode == null) return {};

    scannedBarcode = barcode;
    isCheckingBarcode = true;
    isProductNameLocked = false;
    notifyListeners();

    try {
      final productName = await _productService.getProductNameByBarcode(
        barcode,
      );

      if (productName != null) {
        isProductNameLocked = true; // ← lock field nama
      }

      notifyListeners();
      return {'barcode': barcode, 'productName': productName};
    } catch (e) {
      return {'barcode': barcode, 'productName': null};
    } finally {
      isCheckingBarcode = false;
      notifyListeners();
    }
  }
}

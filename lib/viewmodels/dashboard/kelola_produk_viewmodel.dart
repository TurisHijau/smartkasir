import 'package:flutter/material.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/services/product_service.dart';

class KelolaProdukViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  bool isLoading = false;
  String? errorMessage;

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

  void scanProductCode() {
    // TODO: Implement barcode scanning for product code
  }
}

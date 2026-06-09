import 'package:flutter/material.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/models/stock_movement.dart';
import 'package:smartkasir/services/product_service.dart';
import 'package:smartkasir/services/stock_service.dart';
import 'package:smartkasir/services/auth_service.dart';
import 'package:smartkasir/views/dashboard/kelola_produk_view.dart';

class ListProdukViewmodel extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final StockService _stockService = StockService();
  final AuthService _authService = AuthService();

  bool showFilter = false;
  bool isLoading = false;
  String? errorMessage;
  bool isCashier = false;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';

  List<Product> get products => _filteredProducts;
  bool get hasProduct => _filteredProducts.isNotEmpty;

  ListProdukViewmodel() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final results = await Future.wait([
        _productService.getAll(),
        _authService.getProfile().catchError((_) => null),
      ]);

      _allProducts = results[0] as List<Product>;
      final profile = results[1] as AuthResponse?;

      if (profile != null && profile.user.role.name == 'CASHIER') {
        isCashier = true;
      }

      _applyFilter();
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts.where((p) {
        return p.name.toLowerCase().contains(_searchQuery) ||
            (p.barcode?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
  }

  void toggleFilter() {
    showFilter = !showFilter;
    notifyListeners();
  }

  void navigateToAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KelolaProdukView()),
    ).then((_) => loadProducts());
  }

  void navigateToEditProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KelolaProdukView(product: product),
      ),
    ).then((_) => loadProducts());
  }

  Future<void> deleteProduct(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Produk"),
        content: Text("Yakin ingin menghapus \"${product.name}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true && product.id != null) {
      try {
        await _productService.delete(product.id!);
        await loadProducts();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("\"${product.name}\" berhasil dihapus")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menghapus: $e"),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      }
    }
  }

  // ── Stock dialog ──────────────────────────────────────────────────────────

  void showAddStockDialog(BuildContext context, Product product) {
    final jumlahController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nama Produk",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: product.name),
                  readOnly: true,
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.gray,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.gray,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Jumlah",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: jumlahController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: const TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.gray,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (jumlahController.text.isNotEmpty &&
                          product.id != null) {
                        final qty = int.tryParse(jumlahController.text) ?? 0;
                        if (qty > 0) {
                          try {
                            await _stockService.restock(
                              StockRequest(
                                productId: product.id!,
                                quantity: qty,
                                notes: "Restock dari aplikasi",
                              ),
                            );
                            if (context.mounted) Navigator.pop(context);
                            await loadProducts();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Gagal restock: $e"),
                                  backgroundColor: Colors.red[700],
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Tambah Stok",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

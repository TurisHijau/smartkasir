import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/views/dashboard/barcode_scanner_view.dart';
import 'package:smartkasir/viewmodels/dashboard/list_produk_viewmodel.dart';

class ListProdukView extends StatelessWidget {
  const ListProdukView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListProdukViewmodel(),
      child: const _ListProdukScreen(),
    );
  }
}

class _ListProdukScreen extends StatefulWidget {
  const _ListProdukScreen();

  @override
  State<_ListProdukScreen> createState() => _ListProdukScreenState();
}

class _ListProdukScreenState extends State<_ListProdukScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<ListProdukViewmodel>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.tertiary, AppColors.secondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: viewmodel.isCashier
            ? null
            : SizedBox(
                width: 66,
                height: 66,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                  elevation: 4,
                  onPressed: () => viewmodel.navigateToAddProduct(context),
                  child: const Icon(
                    Icons.add,
                    size: 50,
                    color: AppColors.white,
                  ),
                ),
              ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 30, left: 24, right: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(45),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Cari Produk",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.gray,
                                      width: 1.8,
                                    ),
                                    color: AppColors.lightGray,
                                  ),
                                  child: TextField(
                                    controller: _searchController, // ← tambah
                                    onChanged: viewmodel.search,
                                    decoration: const InputDecoration(
                                      hintText: "Masukkan nama/kode produk",
                                      hintStyle: TextStyle(
                                        color: AppColors.gray,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _actionButton(
                                icon: Icons.qr_code_scanner_rounded,
                                onTap: () async {
                                  final barcode = await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const BarcodeScannerView(),
                                    ),
                                  );
                                  if (barcode != null) {
                                    _searchController.text =
                                        barcode; // ← isi field
                                    viewmodel.search(barcode); // ← filter
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              _actionButton(
                                icon: Icons.filter_alt_rounded,
                                onTap: viewmodel.toggleFilter,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Tap icon untuk membuka scan via kamera",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.gray,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: viewmodel.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : viewmodel.errorMessage != null
                                ? _errorState(viewmodel)
                                : viewmodel.hasProduct
                                ? RefreshIndicator(
                                    onRefresh: viewmodel.loadProducts,
                                    child: ListView.builder(
                                      itemCount: viewmodel.products.length,
                                      itemBuilder: (context, index) {
                                        final product =
                                            viewmodel.products[index];
                                        return _productCard(context, product);
                                      },
                                    ),
                                  )
                                : _emptyState(),
                          ),
                        ],
                      ),
                      if (viewmodel.showFilter)
                        Positioned(
                          top: 86,
                          right: 0,
                          child: Container(
                            width: 260,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Stok",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _filterOption(
                                  text: "Semua",
                                  isSelected: viewmodel.stockFilter == null,
                                  onTap: () {
                                    viewmodel.setStockFilter(null);
                                    viewmodel.toggleFilter();
                                  },
                                ),
                                const SizedBox(height: 6),
                                _filterOption(
                                  text: "Stok Rendah (< 20)",
                                  isSelected: viewmodel.stockFilter == 'low',
                                  onTap: () {
                                    viewmodel.setStockFilter('low');
                                    viewmodel.toggleFilter();
                                  },
                                ),
                                const SizedBox(height: 6),
                                _filterOption(
                                  text: "Stok Habis",
                                  isSelected: viewmodel.stockFilter == 'empty',
                                  onTap: () {
                                    viewmodel.setStockFilter('empty');
                                    viewmodel.toggleFilter();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 27),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Daftar Produk",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 34, color: AppColors.white),
      ),
    );
  }

  Widget _productCard(BuildContext context, Product product) {
    final viewmodel = context.read<ListProdukViewmodel>();

    String formatRupiah(double value) {
      final intVal = value.toInt();
      final str = intVal.toString();
      final result = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) result.write('.');
        result.write(str[i]);
      }
      return result.toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Harga Jual : Rp${formatRupiah(product.sellingPrice)}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Stok : ${product.stock} items",
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
          if (!viewmodel.isCashier)
            Row(
              children: [
                _miniButton(
                  onTap: () => viewmodel.showAddStockDialog(context, product),
                  icon: Icons.add,
                  bgColor: AppColors.lightGreen,
                  iconColor: AppColors.green,
                  iconSize: 26,
                ),
                const SizedBox(width: 6),
                _miniButton(
                  onTap: () =>
                      viewmodel.navigateToEditProduct(context, product),
                  icon: Icons.edit_square,
                  bgColor: AppColors.lightPrimary,
                  iconColor: AppColors.primary,
                ),
                const SizedBox(width: 6),
                _miniButton(
                  onTap: () => viewmodel.deleteProduct(context, product),
                  icon: Icons.delete,
                  bgColor: AppColors.lightRed,
                  iconColor: AppColors.red,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _miniButton({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    double iconSize = 20,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }

  Widget _errorState(ListProdukViewmodel viewmodel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.gray),
          const SizedBox(height: 16),
          Text(
            viewmodel.errorMessage ?? "Terjadi kesalahan",
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.darkGray),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewmodel.loadProducts(),
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 165),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.gray,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag,
                color: AppColors.white,
                size: 57,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Produk Kosong",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "Tambahkan produk dengan menekan\n tombol + di pojok kanan bawah",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterOption({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.lightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.darkGray,
          ),
        ),
      ),
    );
  }
}

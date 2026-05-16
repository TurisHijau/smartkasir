import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
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

class _ListProdukScreen extends StatelessWidget {
  const _ListProdukScreen();

  // FUNGSI UNTUK MENAMPILKAN MODAL TAMBAH STOK
  void _showAddStockDialog(BuildContext context, Map<String, dynamic> product) {
    final jumlahController = TextEditingController();
    final viewmodel = context.read<ListProdukViewmodel>();

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
                // NAMA PRODUK LABEL
                const Text(
                  "Nama Produk",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                // NAMA PRODUK FIELD (READ ONLY)
                TextField(
                  controller: TextEditingController(text: product["nama"]),
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

                // JUMLAH LABEL
                const Text(
                  "Jumlah",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                // INPUT JUMLAH FIELD
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

                // TOMBOL TAMBAH STOK
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // Panggil fungsi tambah stok di viewmodel Anda jika diperlukan
                      // viewmodel.addStock(product, jumlahController.text);
                      Navigator.pop(context);
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
        floatingActionButton: SizedBox(
          width: 66,
          height: 66,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            elevation: 4,
            onPressed: () => viewmodel.navigateToEditProduct(context),
            child: const Icon(Icons.add, size: 50, color: AppColors.white),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 32, left: 22, right: 22),
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
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                  child: const TextField(
                                    decoration: InputDecoration(
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
                                onTap: () {},
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
                            child: viewmodel.hasProduct
                                ? ListView.builder(
                                    itemCount: viewmodel.products.length,
                                    itemBuilder: (context, index) {
                                      final product = viewmodel.products[index];
                                      return _productCard(context, product);
                                    },
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
                                  "Kategori",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _dropdownBox(text: "Pilih Salah Satu Kategori"),
                                const SizedBox(height: 16),
                                const Text(
                                  "Stok",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _dropdownBox(text: "< 20 items"),
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

  Widget _productCard(BuildContext context, Map<String, dynamic> product) {
    final viewmodel = context.read<ListProdukViewmodel>();
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
                  product["nama"],
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Harga : ${product["harga"]}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Stok : ${product["stok"]}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // TOMBOL TAMBAH HIJAU (DIPERBAIKI)
              _miniButton(
                onTap: () => viewmodel.showAddStockDialog(context, product),
                icon: Icons.add,
                bgColor: AppColors.lightGreen,
                iconColor: AppColors.green,
                iconSize: 26,
              ),
              const SizedBox(width: 6),
              _miniButton(
                onTap: () => viewmodel.navigateToEditProduct(context),
                icon: Icons.edit_square,
                bgColor: AppColors.lightPrimary,
                iconColor: AppColors.primary,
              ),
              const SizedBox(width: 6),
              _miniButton(
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

  Widget _dropdownBox({required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.darkGray, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.darkGray,
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
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/viewmodels/dashboard/stock_produk_viewmodel.dart';


class StockProdukView extends StatelessWidget {
  const StockProdukView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StockProdukViewModel(),
      child: const _StockContent(),
    );
  }
}

// ─────────────────────────────────────────────
class _StockContent extends StatelessWidget {
  const _StockContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<StockProdukViewModel>();

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.tertiary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          //  FAB tombol tambah produk
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, viewModel),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 18),
                    decoration: const BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(45),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(45),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            //  Search bar
                            _buildSearchBar(viewModel),
                            const SizedBox(height: 16),

                            //  Filter chips
                            _buildFilterChips(viewModel),
                            const SizedBox(height: 20),

                            //  Label jumlah produk
                            Text(
                              'LIST STOK',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),

                            //  List card produk
                            ...viewModel.filteredProducts.map(
                              (product) => _buildProductCard(product, context),
                            ),

                            //  Tampilan kosong jika tidak ada hasil
                            if (viewModel.filteredProducts.isEmpty)
                              _buildEmptyState(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader(BuildContext context, StockProdukViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 16, 0),
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => viewModel.returnToAnalitik(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Stock Produk',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ──────────────────────────────
  Widget _buildSearchBar(StockProdukViewModel viewModel) {
    return TextField(
      onChanged: viewModel.onSearchChanged, // ← langsung panggil method ViewModel
      decoration: InputDecoration(
        hintText: 'Cari produk...',
        prefixIcon: const Icon(Icons.search, color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ── Filter Chips ────────────────────────────
  Widget _buildFilterChips(StockProdukViewModel viewModel) {
    const filters = ['Semua', 'Rendah', 'Habis'];

    return Row(
      children: filters.map((filter) {
        final isActive = viewModel.activeFilter == filter;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => viewModel.setFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.secondary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.secondary : Colors.black12,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isActive ? AppColors.white : Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Product Card ────────────────────────────
  Widget _buildProductCard(ProductStock product, BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [

        //indikator warna
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: product.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),

        //Nama + stok
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary, // biru
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Stok : ${product.count}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),

        // add
        GestureDetector(
          onTap: () => _showTambahStokDialog(context, product),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.primary,
            ),
          ),
        )
      ],
    ),
  );
}

  // dialog
  void _showTambahStokDialog(BuildContext context, ProductStock product) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: AppColors.lightGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Nama Produk'),
            const SizedBox(height: 10),
            _buildTextField(hintText: product.name, readOnly: true),
            const SizedBox(height: 20),
            _buildLabel('Jumlah'),
            const SizedBox(height: 10),
            _buildTextField(
              hintText: product.count,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),
            _buildTambahStokButton(context),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller, 
    bool readOnly = false,             
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.darkGray
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTambahStokButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Tambah Stok',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.black26),
            SizedBox(height: 12),
            Text(
              'Tidak ada produk ditemukan',
              style: TextStyle(color: Colors.black38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
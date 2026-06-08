import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/utils/currency_input_formatter.dart';
import 'package:smartkasir/viewmodels/dashboard/kelola_produk_viewmodel.dart';
import 'package:intl/intl.dart';

class KelolaProdukView extends StatelessWidget {
  final Product? product;

  const KelolaProdukView({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KelolaProdukViewModel(editingProduct: product),
      child: _KelolaProdukContent(product: product),
    );
  }
}

class _KelolaProdukContent extends StatefulWidget {
  final Product? product;

  const _KelolaProdukContent({this.product});

  @override
  State<_KelolaProdukContent> createState() => _KelolaProdukContentState();
}

class _KelolaProdukContentState extends State<_KelolaProdukContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kodeProdukController = TextEditingController();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaModalController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing
    if (widget.product != null) {
      final p = widget.product!;
      _kodeProdukController.text = p.barcode ?? '';
      _namaProdukController.text = p.name;
      _hargaModalController.text = _formatter.format(p.costPrice.toInt());
      _hargaJualController.text = _formatter.format(p.sellingPrice.toInt());
      _stokController.text = p.stock.toString();
    }
  }

  @override
  void dispose() {
    _kodeProdukController.dispose();
    _namaProdukController.dispose();
    _hargaModalController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<KelolaProdukViewModel>();

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
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, viewModel.isEditMode),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 18),
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  decoration: const BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(45),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Kode Produk'),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _kodeProdukController,
                                  hint: 'Masukkan Kode Produk',
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () async {
                                  await viewModel.scanProductCode(context);
                                  // ← isi controller setelah scan
                                  if (viewModel.scannedBarcode != null) {
                                    _kodeProdukController.text =
                                        viewModel.scannedBarcode!;
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0, left: 4.0),
                            child: Text(
                              'Tap icon untuk membuka scan via kamera',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Nama Produk'),
                          _buildTextField(
                            controller: _namaProdukController,
                            hint: 'Masukkan Nama Produk',
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Harga Modal'),
                          _buildTextField(
                            controller: _hargaModalController,
                            isCurrency: true,
                            hint: 'Masukkan Harga Modal',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Harga Jual'),
                          _buildTextField(
                            controller: _hargaJualController,
                            isCurrency: true,
                            hint: 'Masukkan Harga Jual',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Stok'),
                          _buildTextField(
                            controller: _stokController,
                            isCurrency: false,
                            hint: 'Masukkan Stok Awal',
                            keyboardType: TextInputType.number,
                          ),

                          if (viewModel.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 13,
                              ),
                            ),
                          ],

                          const SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        final success = await viewModel
                                            .saveProduct(
                                              barcode: _kodeProdukController
                                                  .text
                                                  .trim(),
                                              name: _namaProdukController.text
                                                  .trim(),
                                              costPrice: _hargaModalController
                                                  .text
                                                  .replaceAll(
                                                    RegExp(r'[^0-9]'),
                                                    '',
                                                  ),
                                              sellingPrice: _hargaJualController
                                                  .text
                                                  .replaceAll(
                                                    RegExp(r'[^0-9]'),
                                                    '',
                                                  ),
                                              stock: _stokController.text
                                                  .replaceAll(
                                                    RegExp(r'[^0-9]'),
                                                    '',
                                                  ),
                                            );
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                viewModel.isEditMode
                                                    ? "Produk berhasil diupdate"
                                                    : "Produk berhasil ditambahkan",
                                              ),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary
                                    .withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      viewModel.isEditMode
                                          ? 'UPDATE PRODUK'
                                          : 'TAMBAH PRODUK',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
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
    );
  }

  Widget _buildHeader(BuildContext context, bool isEdit) {
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
            Center(
              child: Text(
                isEdit ? 'Edit Produk' : 'Kelola Produk',
                style: const TextStyle(
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    bool isCurrency = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters:
          isCurrency // ← tambah formatter
          ? [CurrencyInputFormatter()]
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.darkGray,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.gray, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.gray, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Field ini tidak boleh kosong';
              }
              return null;
            }
          : null,
    );
  }
}

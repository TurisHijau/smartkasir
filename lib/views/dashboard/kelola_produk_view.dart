import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/utils/currency_input_formatter.dart';
import 'package:smartkasir/viewmodels/dashboard/kelola_produk_viewmodel.dart';
import 'package:smartkasir/widgets/app_ui.dart';
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
      _stokController.text = '0';
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
      decoration: AppUi.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              AppScreenHeader(
                title: viewModel.isEditMode ? 'Edit Produk' : 'Kelola Produk',
              ),
              Expanded(
                child: AppPanel(
                  padding: AppUi.formPanelPadding,
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
                                  final result = await viewModel
                                      .scanProductCode(context);
                                  if (result.isNotEmpty) {
                                    // isi barcode
                                    _kodeProdukController.text =
                                        result['barcode'] ?? '';

                                    // isi nama kalau ditemukan, kosongkan kalau tidak
                                    if (result['productName'] != null) {
                                      _namaProdukController.text =
                                          result['productName']!;
                                    } else {
                                      _namaProdukController.clear();
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
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
                              style: AppTextStyles.helper,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Nama Produk'),
                          _buildTextField(
                            controller: _namaProdukController,
                            hint: 'Masukkan Nama Produk',
                            enabled: !viewModel.isProductNameLocked,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Harga Modal'),
                          _buildTextField(
                            controller: _hargaModalController,
                            isCurrency: true,
                            hint: 'Masukkan Harga Modal',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Harga Jual'),
                          _buildTextField(
                            controller: _hargaJualController,
                            isCurrency: true,
                            hint: 'Masukkan Harga Jual',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel(
                            viewModel.isEditMode ? 'Tambah Stok' : 'Stok Awal',
                          ),
                          if (viewModel.isEditMode)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 4.0,
                              ),
                              child: Text(
                                'Stok saat ini: ${widget.product?.stock ?? 0} pcs',
                                style: AppTextStyles.helper,
                              ),
                            ),
                          _buildTextField(
                            controller: _stokController,
                            isCurrency: false,
                            hint: viewModel.isEditMode
                                ? 'Masukkan jumlah stok tambahan'
                                : 'Masukkan Stok Awal',
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

                          AppFilledButton(
                            label: viewModel.isEditMode
                                ? 'UPDATE PRODUK'
                                : 'TAMBAH PRODUK',
                            isLoading: viewModel.isLoading,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await viewModel.saveProduct(
                                  barcode: _kodeProdukController.text.trim(),
                                  name: _namaProdukController.text.trim(),
                                  costPrice: _hargaModalController.text
                                      .replaceAll(RegExp(r'[^0-9]'), ''),
                                  sellingPrice: _hargaJualController.text
                                      .replaceAll(RegExp(r'[^0-9]'), ''),
                                  stock: _stokController.text.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  ),
                                );
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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

  Widget _buildLabel(String label) {
    return AppFieldLabel(label);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    bool isCurrency = false,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      inputFormatters:
          isCurrency // ← tambah formatter
          ? [CurrencyInputFormatter()]
          : null,
      decoration: appInputDecoration(
        hint: hint,
        fillColor: enabled
            ? Colors.white.withOpacity(0.7)
            : Colors.grey.shade300,
        focusedBorderSide: const BorderSide(
          color: AppColors.primary,
          width: 2.5,
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

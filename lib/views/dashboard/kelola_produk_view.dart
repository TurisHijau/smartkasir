import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/utils/currency_input_formatter.dart';
import 'package:smartkasir/viewmodels/dashboard/kelola_produk_viewmodel.dart';
import 'package:smartkasir/widgets/app_ui.dart';
import 'package:smartkasir/utils/tutorial_helper.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
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

  // Tutorial Keys
  final GlobalKey _kodeKey = GlobalKey();
  final GlobalKey _namaKey = GlobalKey();
  final GlobalKey _hargaModalKey = GlobalKey();
  final GlobalKey _hargaJualKey = GlobalKey();
  final GlobalKey _stokKey = GlobalKey();
  final GlobalKey _submitKey = GlobalKey();

  // Focus Nodes
  final FocusNode _kodeFocus = FocusNode();
  final FocusNode _namaFocus = FocusNode();
  final FocusNode _hargaModalFocus = FocusNode();
  final FocusNode _hargaJualFocus = FocusNode();
  final FocusNode _stokFocus = FocusNode();

  // Tutorial tracking
  bool _kodeTutorialShown = false;
  bool _namaTutorialShown = false;
  bool _hargaModalTutorialShown = false;
  bool _hargaJualTutorialShown = false;
  bool _stokTutorialShown = false;
  bool _submitTutorialShown = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final phase = await TutorialHelper.getTutorialPhase();
      if (phase == TutorialPhase.addProduct && widget.product == null) {
        _setupTutorialListeners();
        // Request focus on the first field to trigger the first tutorial
        if (mounted) {
          FocusScope.of(context).requestFocus(_kodeFocus);
        }
      }
    });
  }

  void _setupTutorialListeners() {
    _kodeFocus.addListener(() {
      if (_kodeFocus.hasFocus && !_kodeTutorialShown) {
        _kodeTutorialShown = true;
        _showSingleTutorial("kode", _kodeKey, "Kode Produk", "Isi kode barcode secara manual atau gunakan icon scan kamera di sebelah kanan.");
      }
    });
    _namaFocus.addListener(() {
      if (_namaFocus.hasFocus && !_namaTutorialShown) {
        _namaTutorialShown = true;
        _showSingleTutorial("nama", _namaKey, "Nama Produk", "Masukkan nama barang yang akan dijual.");
      }
    });
    _hargaModalFocus.addListener(() {
      if (_hargaModalFocus.hasFocus && !_hargaModalTutorialShown) {
        _hargaModalTutorialShown = true;
        _showSingleTutorial("harga_modal", _hargaModalKey, "Harga Modal", "Harga beli barang, digunakan untuk menghitung keuntungan.");
      }
    });
    _hargaJualFocus.addListener(() {
      if (_hargaJualFocus.hasFocus && !_hargaJualTutorialShown) {
        _hargaJualTutorialShown = true;
        _showSingleTutorial("harga_jual", _hargaJualKey, "Harga Jual", "Harga yang akan dibayar oleh pelanggan.");
      }
    });
    _stokFocus.addListener(() {
      if (_stokFocus.hasFocus && !_stokTutorialShown) {
        _stokTutorialShown = true;
        _showSingleTutorial("stok", _stokKey, "Stok Awal", "Jumlah barang yang tersedia saat ini.");
      } else if (!_stokFocus.hasFocus && _stokTutorialShown && !_submitTutorialShown) {
        // Trigger submit tutorial when stok loses focus
        _submitTutorialShown = true;
        _showSingleTutorial("submit", _submitKey, "Simpan", "Klik tombol ini untuk menyimpan produk ke dalam sistem. Setelah sukses, Anda akan masuk ke tahap berikutnya.");
      }
    });
  }

  void _showSingleTutorial(String identify, GlobalKey keyTarget, String title, String description) {
    if (!mounted) return;
    final targets = [
      TargetFocus(
        identify: identify,
        keyTarget: keyTarget,
        shape: ShapeLightFocus.RRect,
        radius: identify == 'submit' ? 25 : 12,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: identify == 'kode' || identify == 'nama' ? ContentAlign.bottom : ContentAlign.top,
            builder: (context, controller) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(description, style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 20),
                const Text("Tap layar untuk mulai mengisi form", style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
              ],
            ),
          )
        ],
      ),
    ];
    TutorialHelper.showTutorial(context: context, targets: targets);
  }

  @override
  void dispose() {
    _kodeFocus.dispose();
    _namaFocus.dispose();
    _hargaModalFocus.dispose();
    _hargaJualFocus.dispose();
    _stokFocus.dispose();
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
                            key: _kodeKey,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _kodeProdukController,
                                  focusNode: _kodeFocus,
                                  textInputAction: TextInputAction.next,
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
                          Container(
                            key: _namaKey,
                            child: _buildTextField(
                              controller: _namaProdukController,
                              focusNode: _namaFocus,
                              textInputAction: TextInputAction.next,
                              hint: 'Masukkan Nama Produk',
                              enabled: !viewModel.isProductNameLocked,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Harga Modal'),
                          Container(
                            key: _hargaModalKey,
                            child: _buildTextField(
                              controller: _hargaModalController,
                              focusNode: _hargaModalFocus,
                              textInputAction: TextInputAction.next,
                              isCurrency: true,
                              hint: 'Masukkan Harga Modal',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Harga Jual'),
                          Container(
                            key: _hargaJualKey,
                            child: _buildTextField(
                              controller: _hargaJualController,
                              focusNode: _hargaJualFocus,
                              textInputAction: TextInputAction.next,
                              isCurrency: true,
                              hint: 'Masukkan Harga Jual',
                              keyboardType: TextInputType.number,
                            ),
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
                          Container(
                            key: _stokKey,
                            child: _buildTextField(
                              controller: _stokController,
                              focusNode: _stokFocus,
                              textInputAction: TextInputAction.done,
                              isCurrency: false,
                              hint: viewModel.isEditMode
                                  ? 'Masukkan jumlah stok tambahan'
                                  : 'Masukkan Stok Awal',
                              keyboardType: TextInputType.number,
                            ),
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

                          Container(
                            key: _submitKey,
                            child: AppFilledButton(
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
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    bool isCurrency = false,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      enabled: enabled,
      inputFormatters: isCurrency ? [CurrencyInputFormatter()] : null,
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

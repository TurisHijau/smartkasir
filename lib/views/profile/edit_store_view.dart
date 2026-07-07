import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/viewmodels/profile/edit_store_viewmodel.dart';
import 'package:smartkasir/widgets/app_ui.dart';

class EditStoreView extends StatefulWidget {
  final AuthResponse profileData;

  const EditStoreView({super.key, required this.profileData});

  @override
  State<EditStoreView> createState() => _EditStoreViewState();
}

class _EditStoreViewState extends State<EditStoreView> {
  late final TextEditingController _namaToko;
  late final TextEditingController _alamat;
  late final TextEditingController _noTelp;

  @override
  void initState() {
    super.initState();
    _namaToko = TextEditingController(
      text: widget.profileData.store.businessName,
    );
    _alamat = TextEditingController(
      text: widget.profileData.store.address ?? '',
    );
    _noTelp = TextEditingController(
      text: widget.profileData.store.phone ?? '',
    );
  }

  @override
  void dispose() {
    _namaToko.dispose();
    _alamat.dispose();
    _noTelp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditStoreViewModel(),
      child: Consumer<EditStoreViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            decoration: AppUi.gradientBackground,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    const AppScreenHeader(title: 'Edit Profil Toko'),
                    Expanded(
                      child: AppPanel(
                        padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppFieldLabel('Nama Toko', required: true),
                              _buildTextField(
                                controller: _namaToko,
                                hint: 'Masukkan Nama Toko',
                              ),

                              const SizedBox(height: 20),
                              AppFieldLabel('Alamat Toko'),
                              _buildTextField(
                                controller: _alamat,
                                hint: 'Masukkan Alamat Toko',
                                maxLines: 3,
                              ),

                              const SizedBox(height: 20),
                              AppFieldLabel('No. Telepon Toko'),
                              _buildTextField(
                                controller: _noTelp,
                                hint: 'Masukkan No. Telepon',
                                keyboardType: TextInputType.phone,
                              ),

                              const SizedBox(height: 20),

                              // Error message
                              if (viewModel.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    viewModel.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Selesai Button
                              AppFilledButton(
                                label: 'SELESAI',
                                isLoading: viewModel.isLoading,
                                height: 55,
                                onPressed: () async {
                                  final success = await viewModel.updateStore(
                                    context,
                                    storeId:
                                        widget.profileData.store.id ?? '',
                                    businessName: _namaToko.text,
                                    address: _alamat.text,
                                    phone: _noTelp.text,
                                  );
                                  if (success && context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: appInputDecoration(
        hint: hint,
        enabledBorderSide: BorderSide.none,
      ),
    );
  }
}

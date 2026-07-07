import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/viewmodels/dashboard/kelola_pegawai_viewmodel.dart';
import 'package:smartkasir/widgets/app_ui.dart';

class KelolaPegawaiView extends StatelessWidget {
  final User? user;

  const KelolaPegawaiView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KelolaPegawaiViewModel(editingUser: user),
      child: _KelolaPegawaiContent(user: user),
    );
  }
}

class _KelolaPegawaiContent extends StatefulWidget {
  final User? user;

  const _KelolaPegawaiContent({this.user});

  @override
  State<_KelolaPegawaiContent> createState() => _KelolaPegawaiContentState();
}

class _KelolaPegawaiContentState extends State<_KelolaPegawaiContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaPegawaiController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final u = widget.user!;
      _namaPegawaiController.text = u.name;
      _usernameController.text = u.username;
      _noTelpController.text = u.phone ?? '';
    }
  }

  @override
  void dispose() {
    _namaPegawaiController.dispose();
    _usernameController.dispose();
    _noTelpController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<KelolaPegawaiViewModel>();

    return Container(
      decoration: AppUi.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              AppScreenHeader(
                title: viewModel.isEditMode ? 'Edit Pegawai' : 'Kelola Pegawai',
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
                          _buildLabel('Nama Pegawai'),
                          _buildTextField(
                            controller: _namaPegawaiController,
                            hint: 'Masukkan Nama Pegawai',
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Username'),
                          _buildTextField(
                            controller: _usernameController,
                            hint: 'Masukkan Username',
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('No Telp'),
                          _buildTextField(
                            controller: _noTelpController,
                            hint: 'Masukkan No Telepon',
                            keyboardType: TextInputType.phone,
                            required: false,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Role'),
                          viewModel.isEditingOwner
                              ? _buildReadOnlyRole()
                              : _buildRoleDropdown(viewModel),
                          const SizedBox(height: 16),

                          _buildLabel('Password'),
                          _buildTextField(
                            controller: _passwordController,
                            hint: viewModel.isEditMode
                                ? 'Kosongkan jika tidak diubah'
                                : 'Masukkan Password',
                            obscureText: viewModel.obscurePassword,
                            onSuffixIconTap: viewModel.togglePasswordVisibility,
                            required: !viewModel.isEditMode,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Konfirmasi Password'),
                          _buildTextField(
                            controller: _konfirmasiPasswordController,
                            hint: 'Masukkan Kembali Password',
                            obscureText: viewModel.obscureConfirmPassword,
                            onSuffixIconTap:
                                viewModel.toggleConfirmPasswordVisibility,
                            required: !viewModel.isEditMode,
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
                                ? 'UPDATE PEGAWAI'
                                : 'TAMBAH PEGAWAI',
                            isLoading: viewModel.isLoading,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_passwordController.text.isNotEmpty &&
                                    _passwordController.text !=
                                        _konfirmasiPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Password tidak cocok'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final password =
                                    _passwordController.text.isNotEmpty
                                    ? _passwordController.text
                                    : 'unchanged';

                                final success = await viewModel.saveEmployee(
                                  name: _namaPegawaiController.text.trim(),
                                  username: _usernameController.text.trim(),
                                  phone: _noTelpController.text.trim(),
                                  password: password,
                                );

                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        viewModel.isEditMode
                                            ? "Pegawai berhasil diupdate"
                                            : "Pegawai berhasil ditambahkan",
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

  Widget _buildRoleDropdown(KelolaPegawaiViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Role>(
          value: viewModel.selectedRole,
          isExpanded: true,
          style: const TextStyle(
            color: AppColors.darkGray,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
          items: const [
            DropdownMenuItem(value: Role.CASHIER, child: Text('Staff / Kasir')),
            DropdownMenuItem(
              value: Role.MANAGER,
              child: Text('Manajer / Kepala Toko'),
            ),
          ],
          onChanged: (role) {
            if (role != null) viewModel.setRole(role);
          },
        ),
      ),
    );
  }

  Widget _buildReadOnlyRole() {
    return Container(
      width: double.infinity,
      padding: AppUi.inputPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: const Text(
        'Pemilik Toko',
        style: TextStyle(
          color: AppColors.darkGray,
          fontWeight: FontWeight.w600,
          fontSize: 16,
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
    bool obscureText = false,
    VoidCallback? onSuffixIconTap,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: appInputDecoration(
        hint: hint,
        fillColor: Colors.white.withValues(alpha: 0.7),
        suffixIcon: onSuffixIconTap != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                  size: 22,
                ),
                onPressed: onSuffixIconTap,
              )
            : null,
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

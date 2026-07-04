import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/viewmodels/dashboard/kelola_pegawai_viewmodel.dart';

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
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
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
                          _buildRoleDropdown(viewModel),
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

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        if (_passwordController
                                                .text
                                                .isNotEmpty &&
                                            _passwordController.text !=
                                                _konfirmasiPasswordController
                                                    .text) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Password tidak cocok',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        final password =
                                            _passwordController.text.isNotEmpty
                                            ? _passwordController.text
                                            : 'unchanged';

                                        final success = await viewModel
                                            .saveEmployee(
                                              name: _namaPegawaiController.text
                                                  .trim(),
                                              username: _usernameController.text
                                                  .trim(),
                                              phone: _noTelpController.text
                                                  .trim(),
                                              password: password,
                                            );

                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
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
                                          ? 'UPDATE PEGAWAI'
                                          : 'TAMBAH PEGAWAI',
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

  Widget _buildRoleDropdown(KelolaPegawaiViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
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
                isEdit ? 'Edit Pegawai' : 'Kelola Pegawai',
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.darkGray,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
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

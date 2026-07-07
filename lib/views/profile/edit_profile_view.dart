import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/viewmodels/profile/edit_profile_viewmodel.dart';
import 'package:smartkasir/widgets/app_ui.dart';

class EditProfileView extends StatefulWidget {
  final AuthResponse profileData; // ← terima data profil yang sudah ada

  const EditProfileView({super.key, required this.profileData});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _noTelpController;

  @override
  void initState() {
    super.initState();
    // Pre-fill dengan data yang sudah ada
    _namaController = TextEditingController(text: widget.profileData.user.name);
    _emailController = TextEditingController(
      text: widget.profileData.user.email ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.profileData.user.username,
    );
    _passwordController = TextEditingController();
    _noTelpController = TextEditingController(
      text: widget.profileData.store.phone ?? '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(),
      child: Consumer<EditProfileViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            decoration: AppUi.gradientBackground,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    const AppScreenHeader(title: 'Edit Profil'),
                    Expanded(
                      child: AppPanel(
                        padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Nama", required: true),
                              _buildTextField(
                                controller: _namaController,
                                hint: "Masukkan Nama",
                              ),

                              const SizedBox(height: 20),
                              _buildLabel("Email"),
                              _buildTextField(
                                controller: _emailController,
                                hint: "Masukkan Email",
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 20),
                              _buildLabel("Username"),
                              _buildTextField(
                                controller: _usernameController,
                                hint: "Masukkan Username",
                              ),

                              const SizedBox(height: 20),
                              _buildLabel("Password Baru"),
                              _buildTextField(
                                controller: _passwordController,
                                hint: "Kosongkan jika tidak ingin diubah",
                                obscureText: true,
                              ),

                              const SizedBox(height: 20),
                              _buildLabel("No Telp"),
                              _buildTextField(
                                controller: _noTelpController,
                                hint: "Masukkan No Telepon",
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
                                  final success = await viewModel.updateProfile(
                                    context,
                                    userId: widget.profileData.user.id ?? '',
                                    name: _namaController.text,
                                    email: _emailController.text,
                                    username: _usernameController.text,
                                    password: _passwordController.text,
                                    role: widget.profileData.user.role.name,
                                    phone: _noTelpController.text,
                                  );
                                  if (success && context.mounted) {
                                    Navigator.pop(
                                      context,
                                    ); // ← kembali ke ProfileView
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

  Widget _buildLabel(String text, {bool required = false}) {
    return AppFieldLabel(text, required: required);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: appInputDecoration(
        hint: hint,
        enabledBorderSide: BorderSide.none,
      ),
    );
  }
}

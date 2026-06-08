import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/auth.dart';
import 'package:smartkasir/viewmodels/profile/edit_profile_viewmodel.dart';

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
                    _buildHeader(context),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 18),
                        padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                        decoration: const BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(45),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Nama", required: true),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _namaController,
                                hint: "Masukkan Nama",
                              ),

                              const SizedBox(height: 20),
                              _buildLabel("Email"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _emailController,
                                hint: "Masukkan Email",
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 20),
                              _buildLabel("Username"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _usernameController,
                                hint: "Masukkan Username",
                              ),

                              const SizedBox(height: 20),
                              _buildLabel("Password Baru"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _passwordController,
                                hint: "Masukkan Password Baru",
                                obscureText: true,
                              ),

                              const SizedBox(height: 20),
                              _buildLabel("No Telp"),
                              const SizedBox(height: 8),
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
                              SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: ElevatedButton(
                                  onPressed: viewModel.isLoading
                                      ? null
                                      : () async {
                                          final success = await viewModel
                                              .updateProfile(
                                                context,
                                                userId:
                                                    widget
                                                        .profileData
                                                        .user
                                                        .id ??
                                                    '',
                                                name: _namaController.text,
                                                email: _emailController.text,
                                                username:
                                                    _usernameController.text,
                                                password:
                                                    _passwordController.text,
                                                role: widget
                                                    .profileData
                                                    .user
                                                    .role
                                                    .name,
                                                phone: _noTelpController.text,
                                              );
                                          if (success && context.mounted) {
                                            Navigator.pop(
                                              context,
                                            ); // ← kembali ke ProfileView
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: viewModel.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "SELESAI",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
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

  Widget _buildHeader(BuildContext context) {
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
            const Center(
              child: Text(
                'Edit Profil',
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

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        if (required)
          const Text(
            " *",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
      ],
    );
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.darkGray, fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

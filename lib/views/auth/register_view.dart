import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/viewmodels/auth/register_viewmodel.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewmodel(),
      child: Consumer<RegisterViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),

                // Back Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                // Main Content
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.88,
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 36,
                      right: 36,
                      top: 70,
                      bottom: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Center(
                            child: Column(
                              children: [
                                Text(
                                  "DAFTAR",
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Buat akun untuk mengelola toko Anda",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.darkGray,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          if (viewModel.errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      viewModel.errorMessage!,
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Informasi Pemilik
                          const Text(
                            "Informasi Pemilik",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGray,
                            ),
                          ),
                          const SizedBox(height: 24),

                          buildLabel("Nama Lengkap"),
                          buildTextField(
                            "Masukkan nama lengkap Anda",
                            controller: viewModel.ownerNameController,
                          ),
                          const SizedBox(height: 20),

                          buildLabel("Username"),
                          buildTextField(
                            "Masukkan username",
                            controller: viewModel.usernameController,
                          ),
                          const SizedBox(height: 20),

                          buildLabel("Email"),
                          buildTextField(
                            "Masukkan email Anda",
                            controller: viewModel.emailController,
                            type: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          buildLabel("No Handphone"),
                          buildTextField(
                            "Masukkan no HP Anda",
                            controller: viewModel.ownerPhoneController,
                            type: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),

                          buildLabel("Password"),
                          buildTextField(
                            "Masukkan password Anda",
                            controller: viewModel.passwordController,
                            obscure: viewModel.obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                viewModel.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              color: AppColors.gray,
                              onPressed: viewModel.togglePasswordVisibility,
                            ),
                          ),
                          const SizedBox(height: 20),

                          buildLabel("Konfirmasi Password"),
                          buildTextField(
                            "Masukkan kembali password",
                            controller: viewModel.confirmPasswordController,
                            obscure: viewModel.obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                viewModel.obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              color: AppColors.gray,
                              onPressed:
                                  viewModel.toggleConfirmPasswordVisibility,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Data Toko
                          const Text(
                            "Data Toko",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGray,
                            ),
                          ),
                          const SizedBox(height: 24),

                          buildLabel("Nama Toko"),
                          buildTextField(
                            "Masukkan nama toko Anda",
                            controller: viewModel.storeNameController,
                          ),
                          const SizedBox(height: 20),

                          buildLabel("Alamat Toko"),
                          buildTextField(
                            "Masukkan alamat toko Anda",
                            controller: viewModel.storeAddressController,
                          ),
                          const SizedBox(height: 20),

                          buildLabel("No Telepon Toko"),
                          buildTextField(
                            "Masukkan no telepon toko Anda",
                            controller: viewModel.storePhoneController,
                            type: TextInputType.phone,
                          ),
                          const SizedBox(height: 28),

                          // Button
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      final success = await viewModel
                                          .register();
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Registrasi berhasil! Silakan login.',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        viewModel.navigateToLogin(context);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary
                                    .withOpacity(0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: viewModel.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "DAFTAR",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 72),

                          // Login Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Sudah memiliki akun/toko? ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => viewModel.navigateToLogin(context),
                                child: const Text(
                                  "Masuk",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }

  Widget buildTextField(
    String hint, {
    bool obscure = false,
    TextEditingController? controller,
    Widget? suffixIcon,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: suffixIcon,
                )
              : null,
          hintStyle: const TextStyle(
            color: AppColors.darkGray,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          filled: true,
          fillColor: AppColors.lightGray,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: AppColors.darkGray, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

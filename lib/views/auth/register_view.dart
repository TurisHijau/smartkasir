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
                // Background Gradient
                Container(
                  height: MediaQuery.of(context).size.height * 0.28,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.tertiary, AppColors.secondary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
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
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),

                                SizedBox(height: 5),

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

                          buildLabel("Nama Anda"),
                          buildTextField("Masukkan nama Anda"),

                          const SizedBox(height: 20),

                          buildLabel("Email"),
                          buildTextField("Masukkan email Anda"),

                          const SizedBox(height: 20),

                          buildLabel("Password"),
                          buildTextField(
                            "Masukkan password Anda",
                            obscure: true,
                          ),

                          const SizedBox(height: 20),

                          buildLabel("Konfirmasi Password"),
                          buildTextField(
                            "Masukkan kembali password",
                            obscure: true,
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
                          buildTextField("Masukkan nama toko Anda"),

                          const SizedBox(height: 20),

                          buildLabel("Alamat"),
                          buildTextField("Masukkan alamat toko Anda"),

                          const SizedBox(height: 20),

                          buildLabel("No Telepon"),
                          buildTextField("Masukkan no telepon Anda"),

                          const SizedBox(height: 40),

                          // Button
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () =>
                                    viewModel.navigateToLogin(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: SizedBox(
                                child: const Text(
                                  "DAFTAR",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 55),

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
                                onTap: () =>
                                    viewModel.navigateToLogin(context),
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

                          const SizedBox(height: 30),
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

  Widget buildTextField(String hint, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.darkGray,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          filled: true,
          fillColor: AppColors.lightGray,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.darkGray, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

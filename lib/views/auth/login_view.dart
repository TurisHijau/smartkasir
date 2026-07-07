import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/viewmodels/auth/login_viewmodel.dart';
import 'package:smartkasir/widgets/app_ui.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewmodel(),
      child: Consumer<LoginViewmodel>(
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

                // Login Card
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.72,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 40,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.authPanel),
                        topRight: Radius.circular(AppRadius.authPanel),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),

                          // Title
                          const Text(
                            "MASUK",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 2),

                          const Text(
                            "Masuk dengan akun toko/pegawai",
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Email Label
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Username",
                              style: AppTextStyles.authLabel,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Email Field
                          TextField(
                            controller: usernameController,
                            decoration: authInputDecoration(
                              hint: "Masukkan username Anda",
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Password Label
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Password",
                              style: AppTextStyles.authLabel,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Password Field
                          TextField(
                            controller: passwordController,
                            obscureText: viewModel.obscurePassword,
                            decoration: authInputDecoration(
                              hint: "Masukkan password Anda",
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: Icon(
                                    viewModel.obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  color: AppColors.gray,
                                  onPressed: viewModel.togglePasswordVisibility,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  viewModel.navigateToForgotPassword(context),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Lupa password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Login Button
                          AuthFilledButton(
                            label: 'MASUK',
                            isLoading: viewModel.loading,
                            onPressed: () {
                              viewModel.login(
                                context,
                                usernameController.text,
                                passwordController.text,
                              );
                            },
                          ),

                          const SizedBox(height: 72),

                          // Register Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Belum memiliki akun/toko? ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    viewModel.navigateToRegister(context),
                                child: const Text(
                                  "Daftar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
}

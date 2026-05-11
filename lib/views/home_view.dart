import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/viewmodels/home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.tertiary,
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: -160,
                  bottom: -60,
                  child: Opacity(
                    opacity: 0.20,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 530,
                        height: 530,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 40),

                      // Judul
                      Column(
                        children: const [
                          Text(
                            "SMARTKASIR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            "Bisnis Pintar, Mulai dari Sini.",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      // Icon keranjang
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 200,
                            height: 200,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                      // Tombol
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 40,
                        ),
                        child: Column(
                          children: [
                            // Tombol MASUK
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () =>
                                    viewModel.navigateToLogin(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "MASUK",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Tombol DAFTAR TOKO
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: OutlinedButton(
                                onPressed: () =>
                                    viewModel.navigateToRegister(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "DAFTAR TOKO",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

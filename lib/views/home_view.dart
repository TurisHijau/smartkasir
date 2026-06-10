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
      child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutQuart,
          ),
        );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeViewModel>().checkAuth(context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.png', fit: BoxFit.cover),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Judul
                    const Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: Column(
                        children: [
                          Text(
                            "SMARTKASIR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Bisnis Pintar, Mulai dari Sini.",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Icon keranjang
                    Image.asset(
                      'assets/images/logo.png',
                      width: 230,
                      height: 230,
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
                                backgroundColor: AppColors.lightGray,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "MASUK",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
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
                                  color: AppColors.white,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "DAFTAR TOKO",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
            ),
          ),
        ],
      ),
    );
  }
}

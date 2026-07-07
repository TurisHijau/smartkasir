import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/viewmodels/profile/profile_viewmodel.dart';
import 'package:smartkasir/widgets/app_ui.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Container(
      decoration: AppUi.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const AppScreenHeader(title: 'Profil'),
              Expanded(
                child: AppPanel(
                  padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.gray,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.darkGray,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => viewModel.loadProfile(),
                                child: const Text("Coba Lagi"),
                              ),
                            ],
                          ),
                        )
                      : viewModel.profileData == null
                      ? const SizedBox.shrink()
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Header
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        _getInitials(
                                          viewModel.profileData!.user.name,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 40,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      viewModel.profileData!.user.name
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    Text(
                                      _getRoleLabel(
                                        viewModel.profileData!.user.role.name,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.gray,
                                      ),
                                    ),
                                    if (viewModel.profileData!.user.role !=
                                        Role.CASHIER) ...[
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          viewModel.editProfile(context);
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Edit Profil',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Info Section
                              _buildInfoTile(
                                Icons.storefront,
                                'Nama Toko',
                                viewModel.profileData!.store.businessName,
                              ),
                              _buildInfoTile(
                                Icons.person_outline,
                                'Username',
                                viewModel.profileData!.user.username,
                              ),
                              _buildInfoTile(
                                Icons.phone,
                                'No. Telepon Toko',
                                viewModel.profileData!.store.phone ?? '-',
                              ),
                              _buildInfoTile(
                                Icons.email,
                                'Email Pemilik',
                                viewModel.profileData!.user.email ?? '-',
                              ),
                              _buildInfoTile(
                                Icons.location_on,
                                'Alamat',
                                viewModel.profileData!.store.address ?? '-',
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
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  String _getRoleLabel(String roleName) {
    switch (roleName) {
      case 'OWNER':
        return 'Pemilik Toko';
      case 'MANAGER':
        return 'Manajer';
      case 'CASHIER':
        return 'Kasir';
      default:
        return roleName;
    }
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

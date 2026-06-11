import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/viewmodels/settings/settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

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
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Section Header
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        viewModel.profileData != null
                                            ? _getInitials(
                                                viewModel
                                                    .profileData!
                                                    .user
                                                    .name,
                                              )
                                            : 'U',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      viewModel.profileData != null
                                          ? viewModel
                                                .profileData!
                                                .store
                                                .businessName
                                                .toUpperCase()
                                          : 'TOKO',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    TextButton.icon(
                                      onPressed: () =>
                                          viewModel.navigateToProfile(context),
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      label: const Text(
                                        'Profil Detail',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Manajemen Toko Section
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Manajemen Toko',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Analitik - semua role
                              _buildMenuTile(
                                icon: Icons.analytics,
                                title: 'Analitik',
                                subtitle: 'Lihat analisis keuangan toko',
                                onTap: () =>
                                    viewModel.navigateToAnalitik(context),
                              ),

                              // Pegawai - hanya OWNER dan MANAGER
                              if (viewModel.profileData?.user.role !=
                                  Role.CASHIER)
                                _buildMenuTile(
                                  icon: Icons.people,
                                  title: 'Pegawai',
                                  subtitle: 'Buat atau edit akun pegawai',
                                  onTap: () =>
                                      viewModel.navigateToEmploye(context),
                                ),

                              // Produk - semua role
                              _buildMenuTile(
                                icon: Icons.inventory,
                                title: 'Produk',
                                subtitle: 'Kelola list produk',
                                onTap: () =>
                                    viewModel.navigateToProducts(context),
                              ),

                              // Saldo - hanya OWNER
                              if (viewModel.profileData?.user.role ==
                                  Role.OWNER)
                                _buildMenuTile(
                                  icon: Icons.account_balance_wallet,
                                  title: 'Saldo',
                                  subtitle: 'Lihat pembayaran via QRIS',
                                  onTap: () =>
                                      viewModel.navigateToSaldo(context),
                                ),

                              const SizedBox(height: 24),

                              // Pengaturan Perangkat Section
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Pengaturan Perangkat',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildMenuTile(
                                icon: Icons.print,
                                title: 'Printer Struk',
                                subtitle: viewModel.isPrinterConnected 
                                    ? 'Terhubung: ${viewModel.connectedPrinterName}'
                                    : 'Tidak ada koneksi',
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (viewModel.isPrinterConnected)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.print_outlined,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        tooltip: 'Test Print',
                                        onPressed: () => viewModel.testPrint(),
                                      ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.settings,
                                        color: AppColors.gray,
                                      ),
                                      onPressed: () => _showPrinterDialog(context, viewModel),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Hubungkan via Bluetooth to ikon Gear, lalu tap Refresh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Logout Button
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
                                child: InkWell(
                                  onTap: () => viewModel.logout(context),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        222,
                                        17,
                                        2,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.logout, color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          'Keluar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
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
                'Pengaturan',
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

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
                trailing != null
                  ? trailing
                  : const Icon(Icons.chevron_right, color: AppColors.gray),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrinterDialog(BuildContext context, SettingsViewModel viewModel) {
    viewModel.scanPrinters();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final vm = Provider.of<SettingsViewModel>(context);
            return Container(
              padding: const EdgeInsets.all(20),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Printer Bluetooth',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => vm.scanPrinters(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (vm.isScanningPrinter)
                    const Center(child: CircularProgressIndicator())
                  else if (vm.availableBluetoothDevices.isEmpty)
                    const Center(child: Text('Tidak ada perangkat ditemukan.\nPastikan Bluetooth menyala.'))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: vm.availableBluetoothDevices.length,
                        itemBuilder: (context, index) {
                          final device = vm.availableBluetoothDevices[index];
                          final isConnected = vm.connectedPrinterMac == device.macAdress;
                          return ListTile(
                            leading: const Icon(Icons.print),
                            title: Text(device.name),
                            subtitle: Text(device.macAdress),
                            trailing: isConnected
                                ? TextButton(
                                    onPressed: () => vm.disconnectPrinter(),
                                    child: const Text('Putuskan', style: TextStyle(color: Colors.red)),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      vm.connectPrinter(device.macAdress, device.name);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Hubungkan'),
                                  ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

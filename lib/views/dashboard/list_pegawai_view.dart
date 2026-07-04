import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/viewmodels/dashboard/list_pegawai_viewmodel.dart';

class ListPegawaiView extends StatelessWidget {
  const ListPegawaiView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListPegawaiViewmodel(),
      child: const _ListPegawaiContent(),
    );
  }
}

class _ListPegawaiContent extends StatelessWidget {
  const _ListPegawaiContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ListPegawaiViewmodel>();

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Cari Pegawai",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: viewModel.search,
                        decoration: InputDecoration(
                          hintText: "Masukkan nama pegawai",
                          hintStyle: const TextStyle(
                            color: AppColors.gray,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: AppColors.lightGray,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.gray,
                              width: 1.8,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : viewModel.errorMessage != null
                                ? _errorState(viewModel)
                                : viewModel.employees.isEmpty
                                    ? const _EmptyEmployeeState()
                                    : RefreshIndicator(
                                        onRefresh: viewModel.loadUsers,
                                        child: ListView.separated(
                                          itemCount: viewModel.employees.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 14),
                                          itemBuilder: (context, index) {
                                            final user = viewModel.employees[index];
                                            return _EmployeeCard(user: user);
                                          },
                                        ),
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: viewModel.isOwner
            ? SizedBox(
                width: 66,
                height: 66,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                  elevation: 4,
                  onPressed: () => viewModel.navigateToAddEmployee(context),
                  child: const Icon(Icons.add, size: 50, color: AppColors.white),
                ),
              )
            : null,
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
                "Daftar Pegawai",
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

  Widget _errorState(ListPegawaiViewmodel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.gray),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? "Terjadi kesalahan",
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.darkGray),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.loadUsers(),
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }
}

// hapus semua data pegawai di list pegawaiviewmodel jika ingin menampilkan list pegawai kosong
class _EmptyEmployeeState extends StatelessWidget {
  const _EmptyEmployeeState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.gray,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_alt_1,
                color: AppColors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Pegawai Kosong",
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "Tambahkan pegawai dengan menekan\n"
              "tombol + di pojok kanan bawah",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final User user;

  const _EmployeeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ListPegawaiViewmodel>();

    String roleLabel(Role role) {
      switch (role) {
        case Role.OWNER:
          return 'Pemilik';
        case Role.MANAGER:
          return 'Manajer';
        case Role.CASHIER:
          return 'Kasir';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.username,
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      user.phone ?? '-',
                      style: const TextStyle(
                        color: AppColors.darkGray,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleLabel(user.role),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (viewModel.isOwner)
            Row(
              children: [
                _ActionButton(
                  backgroundColor: AppColors.lightPrimary,
                  icon: Icons.edit_square,
                  iconColor: AppColors.primary,
                  onTap: () => viewModel.navigateToEditEmployee(context, user),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  backgroundColor: AppColors.lightRed,
                  icon: Icons.delete,
                  iconColor: Colors.red,
                  onTap: () => viewModel.deleteUser(context, user),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 25,
          color: iconColor,
        ),
      ),
    );
  }
}
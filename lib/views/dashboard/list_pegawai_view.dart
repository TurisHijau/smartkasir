import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
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
                        child: viewModel.employees.isEmpty
                            ? const _EmptyEmployeeState()
                            : ListView.separated(
                                itemCount: viewModel.employees.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final employee = viewModel.employees[index];
                                  return _EmployeeCard(
                                    name: employee["name"] ?? "",
                                    username: employee["username"] ?? "",
                                    phone: employee["phone"] ?? "",
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: SizedBox(
          width: 66,
          height: 66,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            elevation: 4,
            onPressed: () => viewModel.navigateToEditEmployee(context),
            child: const Icon(Icons.add, size: 50, color: AppColors.white),
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
              decoration: BoxDecoration(
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
  final String name;
  final String username;
  final String phone;

  const _EmployeeCard({
    required this.name,
    required this.username,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ListPegawaiViewmodel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  username,
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              _ActionButton(
                backgroundColor: AppColors.lightPrimary,
                icon: Icons.edit_square,
                iconColor: AppColors.primary,
                onTap: () => viewModel.navigateToEditEmployee(context),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                backgroundColor: AppColors.lightRed,
                icon: Icons.delete,
                iconColor: Colors.red,
                onTap: () {},
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
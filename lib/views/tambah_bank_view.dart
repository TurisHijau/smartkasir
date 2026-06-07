import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/viewmodels/tambah_bank_viewmodel.dart';

class TambahBankView extends StatelessWidget {
  const TambahBankView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TambahBankViewModel(),
      child: Consumer<TambahBankViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            // Menghapus backgroundColor lama agar gradient di Container terlihat
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.tertiary, AppColors.secondary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 25,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.white,
                              size: 28,
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Tambah Bank',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                        ],
                      ),
                    ),

                    // CONTENT
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(45),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // NAMA AKUN
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Nama Akun',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: viewModel.namaAkunController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Nama Akun',
                                  hintStyle: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.gray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.lightGray,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 18,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: AppColors.darkGray.withOpacity(
                                        0.4,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // NAMA BANK
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Nama Bank',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    width: 2,
                                    color: AppColors.darkGray.withOpacity(0.4),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: null,
                                    hint: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          padding: const EdgeInsets.all(6),
                                          child: Image.asset(
                                            viewModel.selectedBank.isEmpty
                                                ? 'assets/images/payment/BRI.png'
                                                : viewModel.bankImages[viewModel
                                                      .selectedBank]!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          viewModel.selectedBank.isEmpty
                                              ? 'Pilih Bank'
                                              : viewModel.selectedBank,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                    isExpanded: true,
                                    menuMaxHeight: 350,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.gray,
                                    ),
                                    items: viewModel.bankList.map((bank) {
                                      return DropdownMenuItem(
                                        value: bank,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              padding: const EdgeInsets.all(6),
                                              child: Image.asset(
                                                viewModel.bankImages[bank]!,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Text(
                                              bank,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.darkGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      viewModel.changeBank(value ?? '');
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // NO REKENING
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'No Rekening',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: viewModel.noRekeningController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan No Rekening',
                                  hintStyle: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.gray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.lightGray,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 18,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: AppColors.darkGray.withOpacity(
                                        0.4,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text(
                                    'SELESAI',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 44),
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
}

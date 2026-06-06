import 'package:flutter/material.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/views/dashboard/kelola_produk_view.dart';

class ListProdukViewmodel extends ChangeNotifier {
  bool showFilter = false;

  // ubah jadi false untuk tampilan kosong
  bool hasProduct = true;

  final List<Map<String, dynamic>> products = [
    {
      "nama": "Sosis Kanzler",
      "harga": "Rp10.000,00",
      "stok": "20 items",
    },
    {
      "nama": "Nugget Fiesta",
      "harga": "Rp55.000,00",
      "stok": "10 items",
    },
    {
      "nama": "Suku Ultramilk",
      "harga": "Rp8.000,00",
      "stok": "15 items",
    },
    {
      "nama": "Indomie",
      "harga": "Rp3.500,00",
      "stok": "40 items",
    },
    {
      "nama": "Beras 3KG",
      "harga": "Rp45.000,00",
      "stok": "10 items",
    },
  ];

  void toggleFilter() {
    showFilter = !showFilter;
    notifyListeners();
  }

  void navigateToEditProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KelolaProdukView(),
      ),
    );
  }

  // ===========================================================================
  // FUNGSI DIALOG YANG DIPINDAHKAN KE VIEWMODEL
  // ===========================================================================
  void showAddStockDialog(BuildContext context, Map<String, dynamic> product) {
    final jumlahController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nama Produk",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: product["nama"]),
                  readOnly: true,
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.gray,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.gray,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Jumlah",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: jumlahController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: const TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.gray,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (jumlahController.text.isNotEmpty) {
                        final inputStok = int.tryParse(jumlahController.text) ?? 0;
                        // Eksekusi penambahan stok ke list state
                        addStock(product["nama"], inputStok);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Tambah Stok",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FUNGSI LOGIKA UNTUK UPDATE NILAI STOK DI DALAM LIST
  void addStock(String namaProduk, int jumlahTambah) {
    final index = products.indexWhere((p) => p["nama"] == namaProduk);
    if (index != -1) {
      // Mengambil angka saja dari string data, misal "20 items" -> 20
      final currentStokString = products[index]["stok"] as String;
      final currentStokInt = int.tryParse(currentStokString.split(' ')[0]) ?? 0;

      // Hitung stok baru dan simpan kembali ke list
      final newStok = currentStokInt + jumlahTambah;
      products[index]["stok"] = "$newStok items";
      
      // Beritahu UI untuk render ulang dengan data terbaru
      notifyListeners();
    }
  }
}
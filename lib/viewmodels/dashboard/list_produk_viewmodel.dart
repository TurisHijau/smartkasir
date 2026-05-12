import 'package:flutter/material.dart';

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
      "nama": "Susu Ultramilk",
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
}
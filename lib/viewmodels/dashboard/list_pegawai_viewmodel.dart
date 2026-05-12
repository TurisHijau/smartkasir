import 'package:flutter/material.dart';

class ListPegawaiViewmodel extends ChangeNotifier {
  ListPegawaiViewmodel();

// hapus semua data pegawai jika ingin menampilkan list pegawai kosong
  final List<Map<String, String>> _employees = [
    // { HAPUS SEGINI DARI BUKA KURUNG HINGGA TUTUP KURUNG
    //   "name": "I Putu Dandy Pradnyana",
    //   "username": "putudandy67",
    //   "phone": "081234567890",
    // },
    {
      "name": "I Putu Dandy Pradnyana",
      "username": "putudandy67",
      "phone": "081234567890",
    },
    {
      "name": "Satria Cahya Ramadhani",
      "username": "satriacahya67",
      "phone": "0821234567890",
    },
    {
      "name": "Eki Mukhlis",
      "username": "ekimukhlis67",
      "phone": "0831234567890",
    },
    {
      "name": "I Putu Pranata Ari Wiguna",
      "username": "putupranata67",
      "phone": "0841234567890",
    },
    {
      "name": "Muhammad Rizqi Awwalun",
      "username": "muhammadrizqi67",
      "phone": "0851234567890",
    },
  ];

  List<Map<String, String>> get employees => _employees;
}
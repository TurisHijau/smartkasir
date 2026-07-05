import 'package:flutter/material.dart';

class ProductStock {
  final String name;
  final String count;
  final int quantity;
  final Color color;

  const ProductStock({
    required this.name,
    required this.count,
    required this.quantity,
    required this.color,
  });
}

class StockProdukViewModel extends ChangeNotifier {
  // --- Data asli (tidak berubah) ---
  final List<ProductStock> _allProductStocks = [
    ProductStock(
      name: 'Aqua 600ml',
      count: '3 items',
      quantity: 3,
      color: Color(0xFFEF4444),
    ),
    ProductStock(
      name: 'Milo Sachet',
      count: '4 items',
      quantity: 4,
      color: Color(0xFFEF4444),
    ),
    ProductStock(
      name: 'Indomie',
      count: '15 items',
      quantity: 15,
      color: Color(0xFFF97316),
    ),
    ProductStock(
      name: 'Sarimi',
      count: '20 items',
      quantity: 20,
      color: Color(0xFFF97316),
    ),
    ProductStock(
      name: 'Gas LPG 3KG',
      count: '20 items',
      quantity: 20,
      color: Color(0xFFF97316),
    ),
    ProductStock(
      name: 'Gas LPG 3KG',
      count: '25 items',
      quantity: 25,
      color: Color(0xFF22C55E),
    ),
    ProductStock(
      name: 'Aqua Galon',
      count: '30 items',
      quantity: 30,
      color: Color(0xFF22C55E),
    ),
  ];

  // --- State ---
  String _searchQuery = '';
  String _activeFilter = 'Semua';

  // --- Getter untuk View ---
  String get activeFilter => _activeFilter;

  //  Produk yang sudah difilter + di-search (View pakai ini)
  List<ProductStock> get filteredProducts {
    return _allProductStocks.where((p) {
      // filter by nama
      final matchSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      // filter by stok
      final matchFilter = switch (_activeFilter) {
        'Habis' => p.quantity == 0,
        'Rendah' => p.quantity > 0 && p.quantity <= 5,
        _ => true, // 'Semua'
      };

      return matchSearch && matchFilter;
    }).toList();
  }

  // --- Methods ---
  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void returnToAnalitik(BuildContext context) {
    Navigator.pop(context);
  }
}

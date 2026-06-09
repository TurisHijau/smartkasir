import 'dart:convert';
import 'package:smartkasir/models/product.dart';
import 'package:smartkasir/services/api_client.dart';

class ProductService {
  final ApiClient _api = ApiClient();

  Future<List<Product>> getAll() async {
    final response = await _api.get('/products');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception("Gagal memuat produk: ${response.statusCode}");
  }

  Future<Product> create(Product product) async {
    final response = await _api.post('/products', body: product.toJson());
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception("Gagal menambah produk: ${response.statusCode} - ${response.body}");
  }

  Future<Product> update(String id, Product product) async {
    final response = await _api.put('/products/$id', body: product.toJson());
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception("Gagal mengupdate produk: ${response.statusCode} - ${response.body}");
  }

  Future<void> delete(String id) async {
    final response = await _api.delete('/products/$id');
    if (response.statusCode != 204) {
      throw Exception("Gagal menghapus produk: ${response.statusCode}");
    }
  }

  Future<Product?> findByBarcode(String barcode) async {
    final response = await _api.get('/products/barcode/$barcode');
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    // Product not found
    return null;
  }
}

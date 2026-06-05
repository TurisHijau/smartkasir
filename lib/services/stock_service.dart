import 'dart:convert';
import 'package:smartkasir/models/stock_movement.dart';
import 'package:smartkasir/services/api_client.dart';

class StockService {
  final ApiClient _api = ApiClient();

  Future<StockMovement> restock(StockRequest request) async {
    final response = await _api.post('/stock/restock', body: request.toJson());
    if (response.statusCode == 200) {
      return StockMovement.fromJson(jsonDecode(response.body));
    }
    throw Exception("Gagal restock: ${response.statusCode} - ${response.body}");
  }

  Future<StockMovement> adjust(StockRequest request) async {
    final response = await _api.post('/stock/adjustment', body: request.toJson());
    if (response.statusCode == 200) {
      return StockMovement.fromJson(jsonDecode(response.body));
    }
    throw Exception("Gagal adjustment stok: ${response.statusCode} - ${response.body}");
  }

  Future<List<StockMovement>> getHistory(String productId) async {
    final response = await _api.get('/stock/history/$productId');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => StockMovement.fromJson(json)).toList();
    }
    throw Exception("Gagal memuat riwayat stok: ${response.statusCode}");
  }
}

import 'dart:convert';
import 'package:smartkasir/models/transaction.dart';
import 'package:smartkasir/services/api_client.dart';

class TransactionService {
  final ApiClient _api = ApiClient();

  Future<List<Transaction>> getAll() async {
    final response = await _api.get('/transactions');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) {
        // Current API returns { "transaction": {...} }.
        // Keep the direct shape fallback for older local builds.
        if (json.containsKey('transaction')) {
          return Transaction.fromJson(json['transaction']);
        }
        return Transaction.fromJson(json);
      }).toList();
    }
    throw Exception("Gagal memuat transaksi: ${response.statusCode}");
  }

  Future<Transaction> create(TransactionRequest request) async {
    final response = await _api.post('/transactions', body: request.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      if (json.containsKey('transaction')) {
        return Transaction.fromJson(json['transaction']);
      }
      return Transaction.fromJson(json);
    }
    throw Exception(
      "Gagal membuat transaksi: ${response.statusCode} - ${response.body}",
    );
  }

  Future<Transaction> getById(String id) async {
    final response = await _api.get('/transactions/$id');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json.containsKey('transaction')) {
        return Transaction.fromJson(json['transaction']);
      }
      return Transaction.fromJson(json);
    }
    throw Exception("Gagal memuat detail transaksi: ${response.statusCode}");
  }

  Future<void> delete(String id) async {
    final response = await _api.delete('/transactions/$id');
    if (response.statusCode != 204) {
      throw Exception("Gagal menghapus transaksi: ${response.statusCode}");
    }
  }
}

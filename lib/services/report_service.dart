import 'dart:convert';

import 'package:smartkasir/models/report.dart';
import 'package:smartkasir/services/api_client.dart';

class ReportService {
  final ApiClient _api = ApiClient();

  /// Get daily sales report. [date] format: yyyy-MM-dd
  Future<Map<String, dynamic>> getDailySales({String? date}) async {
    final params = <String, String>{};
    if (date != null) params['date'] = date;
    final response = await _api.get(
      '/reports/daily-sales',
      queryParams: params,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception("Gagal memuat laporan harian: ${response.statusCode}");
  }

  /// Get monthly sales report.
  Future<Map<String, dynamic>> getMonthlySales({int? month, int? year}) async {
    final params = <String, String>{};
    if (month != null) params['month'] = month.toString();
    if (year != null) params['year'] = year.toString();
    final response = await _api.get(
      '/reports/monthly-sales',
      queryParams: params,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception("Gagal memuat laporan bulanan: ${response.statusCode}");
  }

  /// Get top selling products within a date range.
  /// [startDate] and [endDate] format: yyyy-MM-dd
  Future<List<TopProductDTO>> getTopProducts({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    final response = await _api.get(
      '/reports/top-products',
      queryParams: params,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TopProductDTO.fromJson(json)).toList();
    }
    throw Exception("Gagal memuat produk terlaris: ${response.statusCode}");
  }

  /// Get owner dashboard analytics. [date] format: yyyy-MM-dd.
  Future<DashboardModel> getDashboard({String? date}) async {
    final params = <String, String>{};
    if (date != null) params['date'] = date;
    final response = await _api.get('/reports/dashboard', queryParams: params);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return DashboardModel.fromJson(data);
    }
    throw Exception("Gagal memuat dashboard: ${response.statusCode}");
  }
}

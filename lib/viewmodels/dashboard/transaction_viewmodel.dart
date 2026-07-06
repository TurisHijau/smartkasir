import 'package:flutter/material.dart';
import 'package:smartkasir/models/transaction.dart';
import 'package:smartkasir/services/transaction_service.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  bool isLoading = false;
  String? errorMessage;
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  String _searchQuery = '';

  List<Transaction> get transactions => _filteredTransactions;

  TransactionViewModel() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      _allTransactions = await _transactionService.getAll();
      
      // Sort by transactionDate descending if available
      _allTransactions.sort((a, b) {
        final aDate = a.transactionDate ?? DateTime(2000);
        final bDate = b.transactionDate ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      _applyFilter();
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredTransactions = List.from(_allTransactions);
    } else {
      _filteredTransactions = _allTransactions.where((t) {
        final code = t.transactionCode?.toLowerCase() ?? '';
        final method = t.paymentMethod.name.toLowerCase();
        return code.contains(_searchQuery) || method.contains(_searchQuery);
      }).toList();
    }
  }

  String formatRupiah(double value) {
    final intVal = value.toInt();
    final str = intVal.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write('.');
      result.write(str[i]);
    }
    return result.toString();
  }

  String formatDate(DateTime? date) {
      if (date == null) return '-';
      final localDate = date.toLocal();
      final dayNames = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      final monthNames = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
  
      final weekday = dayNames[localDate.weekday - 1];
      final day = localDate.day.toString().padLeft(2, '0');
      final month = monthNames[localDate.month];
      final year = localDate.year;
      final hour = localDate.hour.toString().padLeft(2, '0');
      final minute = localDate.minute.toString().padLeft(2, '0');
  
      return '$weekday, $day $month $year $hour:$minute';
    }
}

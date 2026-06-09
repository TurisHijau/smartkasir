import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/models/transaction.dart';
import 'package:smartkasir/viewmodels/dashboard/transaction_viewmodel.dart';

class TransactionView extends StatelessWidget {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionViewModel(),
      child: const _TransactionContent(),
    );
  }
}

class _TransactionContent extends StatelessWidget {
  const _TransactionContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.tertiary, AppColors.secondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 18),
                  padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                  decoration: const BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(45),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Cari Transaksi",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: viewModel.search,
                        decoration: InputDecoration(
                          hintText: "Cari berdasarkan kode atau metode bayar",
                          hintStyle: const TextStyle(
                            color: AppColors.gray,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.gray,
                              width: 1.8,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : viewModel.errorMessage != null
                                ? _buildErrorState(viewModel)
                                : viewModel.transactions.isEmpty
                                    ? const _EmptyTransactionState()
                                    : RefreshIndicator(
                                        onRefresh: viewModel.loadTransactions,
                                        child: ListView.separated(
                                          itemCount: viewModel.transactions.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 14),
                                          itemBuilder: (context, index) {
                                            final tx = viewModel.transactions[index];
                                            return _TransactionCard(tx: tx);
                                          },
                                        ),
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 16, 0),
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
            const Center(
              child: Text(
                "Riwayat Transaksi",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(TransactionViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.gray),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? "Terjadi kesalahan",
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.darkGray, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.loadTransactions(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactionState extends StatelessWidget {
  const _EmptyTransactionState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.gray,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                color: AppColors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Transaksi Kosong",
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "Belum ada riwayat transaksi masuk.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction tx;

  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TransactionViewModel>();

    Color getPaymentColor(PaymentMethod method) {
      switch (method) {
        case PaymentMethod.CASH:
          return AppColors.green;
        case PaymentMethod.QRIS:
          return AppColors.primary;
        case PaymentMethod.DEBIT:
          return Colors.purple;
        case PaymentMethod.CREDIT:
          return Colors.orange;
      }
    }

    return InkWell(
      onTap: () => _showDetailBottomSheet(context, viewModel),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: getPaymentColor(tx.paymentMethod).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                color: getPaymentColor(tx.paymentMethod),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.transactionCode ?? "TX-${tx.id?.substring(0, 8) ?? 'UNKNOWN'}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.formatDate(tx.transactionDate),
                    style: const TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: getPaymentColor(tx.paymentMethod).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tx.paymentMethod.name,
                      style: TextStyle(
                        color: getPaymentColor(tx.paymentMethod),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "Rp${viewModel.formatRupiah(tx.totalAmount)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailBottomSheet(BuildContext context, TransactionViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "Detail Transaksi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              _buildDetailRow("Kode Transaksi", tx.transactionCode ?? "-"),
              _buildDetailRow("Waktu Transaksi", viewModel.formatDate(tx.transactionDate)),
              _buildDetailRow("Metode Pembayaran", tx.paymentMethod.name),
              const Divider(height: 24),
              _buildDetailRow("Total Belanja", "Rp${viewModel.formatRupiah(tx.totalAmount)}", isBold: true),
              _buildDetailRow("Jumlah Bayar", "Rp${viewModel.formatRupiah(tx.amountPaid)}"),
              _buildDetailRow("Kembalian", "Rp${viewModel.formatRupiah(tx.changeAmount)}"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBold ? AppColors.primary : AppColors.black,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

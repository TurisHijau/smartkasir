import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:smartkasir/widgets/app_ui.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  static const String supportEmail = 'support@smartkasir.id';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppUi.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const AppScreenHeader(title: 'Lupa Password'),
              Expanded(
                child: AppPanel(
                  padding: AppUi.formPanelPadding,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Untuk keamanan akun, reset password diproses manual oleh tim SMARTKASIR.',
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _InfoBlock(
                          title: 'Kirim email ke',
                          child: Row(
                            children: [
                              const Expanded(
                                child: SelectableText(
                                  supportEmail,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Salin email',
                                onPressed: () => _copyEmail(context),
                                icon: const Icon(
                                  Icons.copy_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _InfoBlock(
                          title: 'Format email',
                          child: SelectableText(
                            'Subjek: Reset Password SMARTKASIR - [Username]\n\n'
                            'Nama lengkap:\n'
                            'Username:\n'
                            'Nama toko:\n'
                            'Role akun: Owner / Manager / Kasir\n'
                            'Nomor HP terdaftar:\n'
                            'Email terdaftar:\n'
                            'Alasan reset password:',
                            style: TextStyle(
                              color: AppColors.darkGray,
                              fontSize: 14,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _InfoBlock(
                          title: 'Waktu proses',
                          child: Text(
                            'Permintaan akan diverifikasi dan diproses dalam 1-3 hari kerja. Jangan mengirimkan password lama atau data sensitif lain di email.',
                            style: TextStyle(
                              color: AppColors.darkGray,
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: supportEmail));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Email berhasil disalin')));
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoBlock({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUi.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.analyticsCardTitle),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

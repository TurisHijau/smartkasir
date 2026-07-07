import 'package:flutter/material.dart';
import 'package:smartkasir/constants/app_colors.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 18;
  static const double button = 20;
  static const double panel = 45;
  static const double authPanel = 50;
}

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    color: AppColors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle fieldLabel = TextStyle(
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle fieldHint = TextStyle(
    color: AppColors.darkGray,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle searchLabel = TextStyle(
    color: AppColors.primary,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle helper = TextStyle(
    color: AppColors.gray,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle primaryButton = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle authLabel = TextStyle(
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle authHint = TextStyle(
    color: AppColors.darkGray,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle authButton = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle listTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle listBodyStrong = TextStyle(
    color: AppColors.darkGray,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle listBody = TextStyle(
    color: AppColors.darkGray,
    fontSize: 13,
  );

  static const TextStyle listBadge = TextStyle(
    color: AppColors.primary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle analyticsSectionTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle analyticsCardTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle analyticsValue = TextStyle(
    color: AppColors.black,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle analyticsEmptyTitle = TextStyle(
    color: AppColors.darkGray,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle analyticsRowTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle analyticsCaption = TextStyle(
    color: AppColors.darkGray,
    fontSize: 12,
  );

  static const TextStyle analyticsLink = TextStyle(
    color: AppColors.darkGray,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}

class AppUi {
  const AppUi._();

  static const BoxDecoration gradientBackground = BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.tertiary, AppColors.secondary],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const EdgeInsets screenHeaderPadding = EdgeInsets.fromLTRB(
    10,
    12,
    16,
    0,
  );

  static const EdgeInsets panelPadding = EdgeInsets.fromLTRB(20, 30, 20, 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets formPanelPadding = EdgeInsets.fromLTRB(
    24,
    40,
    24,
    30,
  );
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 15,
  );

  static const BorderRadius panelBorderRadius = BorderRadius.vertical(
    top: Radius.circular(AppRadius.panel),
  );

  static const BorderSide inputBorderSide = BorderSide(
    color: AppColors.primary,
    width: 1.5,
  );

  static const BorderSide focusedInputBorderSide = BorderSide(
    color: AppColors.primary,
    width: 2,
  );
}

class AppScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUi.screenHeaderPadding,
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack ?? () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
            Center(child: Text(title, style: AppTextStyles.screenTitle)),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ),
      ),
    );
  }
}

class AppPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool clip;

  const AppPanel({
    super.key,
    required this.child,
    this.padding = AppUi.panelPadding,
    this.margin = const EdgeInsets.only(top: 18),
    this.clip = false,
  });

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: const BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: AppUi.panelBorderRadius,
      ),
      child: child,
    );

    if (!clip) return panel;

    return ClipRRect(borderRadius: AppUi.panelBorderRadius, child: panel);
  }
}

class AppFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;

  const AppFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(label, style: AppTextStyles.primaryButton),
      ),
    );
  }
}

class AuthFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(label, style: AppTextStyles.authButton),
      ),
    );
  }
}

class AppFieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const AppFieldLabel(this.label, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.fieldLabel),
          if (required)
            const Text(
              ' *',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

InputDecoration appInputDecoration({
  required String hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
  Color fillColor = Colors.white,
  BorderSide enabledBorderSide = AppUi.inputBorderSide,
  BorderSide focusedBorderSide = AppUi.focusedInputBorderSide,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.fieldHint,
    filled: true,
    fillColor: fillColor,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    contentPadding: AppUi.inputPadding,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: enabledBorderSide,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: enabledBorderSide,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: focusedBorderSide,
    ),
  );
}

InputDecoration authInputDecoration({
  required String hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    suffixIcon: suffixIcon,
    hintStyle: AppTextStyles.authHint,
    filled: true,
    fillColor: AppColors.lightGray,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: AppColors.darkGray, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}

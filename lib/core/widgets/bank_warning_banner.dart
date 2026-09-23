import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BankWarningBanner extends StatelessWidget {
  final String customMessage;

  const BankWarningBanner({
    super.key,
    this.customMessage =
        'O SIAO é um sistema de registro gerencial e prestação de contas. NÃO realiza PIX, transferências bancárias reais ou pagamentos.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warningBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFD97706),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              customMessage,
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

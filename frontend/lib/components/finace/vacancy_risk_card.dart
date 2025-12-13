import 'package:flutter/material.dart';
import '../../core/utils/app_formatters.dart';

class VacancyRiskCard extends StatelessWidget {
  final double custoMensal;

  const VacancyRiskCard({super.key, required this.custoMensal});

  @override
  Widget build(BuildContext context) {
    final colorNegative = Colors.red.shade400;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colorNegative, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Risco de Vacância",
                  style: TextStyle(
                    color: colorNegative,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Imóvel vazio custa ${AppFormatters.formatCurrency(custoMensal)}/mês.",
                  style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

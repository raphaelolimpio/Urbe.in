import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';

class CapexStructureCard extends StatelessWidget {
  final double valorCompra;
  final double valorReforma;
  final double depreciacaoAnual;
  final double investimentoTotal;

  const CapexStructureCard({
    super.key,
    required this.valorCompra,
    required this.valorReforma,
    required this.depreciacaoAnual,
    required this.investimentoTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _rowValue("Valor de Compra", valorCompra),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Reformas/Capex",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 12, color: Colors.blue),
                ],
              ),
              Text(
                AppFormatters.formatCurrency(valorReforma),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          _rowValue(
            "Depreciação Anual (Est.)",
            depreciacaoAnual,
            isNegative: true,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "INVESTIMENTO TOTAL",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                AppFormatters.formatCurrency(investimentoTotal),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rowValue(String label, double value, {bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(
          "${isNegative ? '-' : ''}${AppFormatters.formatCurrency(value)}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isNegative ? Colors.orange.shade800 : Colors.black87,
          ),
        ),
      ],
    );
  }
}

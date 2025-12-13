import 'package:flutter/material.dart';
import '../../core/utils/app_formatters.dart';

class FinanceIndicatorsGrid extends StatelessWidget {
  final double paybackAnos;
  final double valorM2;
  final String statusOcupacao;
  final double yieldMensal;

  const FinanceIndicatorsGrid({
    super.key,
    required this.paybackAnos,
    required this.valorM2,
    required this.statusOcupacao,
    required this.yieldMensal,
  });

  @override
  Widget build(BuildContext context) {
    final colorNeutral = Colors.blueGrey.shade700;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _kpiCard(
          "Payback Estimado",
          "${paybackAnos.toStringAsFixed(1)} anos",
          Icons.history,
          colorNeutral,
        ),
        _kpiCard(
          "Valor do m²",
          AppFormatters.formatCurrency(valorM2),
          Icons.square_foot,
          colorNeutral,
        ),
        _kpiCard(
          "Ocupação",
          statusOcupacao == 'locado' ? "100%" : "0%",
          Icons.people_outline,
          colorNeutral,
        ),
        _kpiCard(
          "Yield Mensal",
          "${yieldMensal.toStringAsFixed(2)}%",
          Icons.pie_chart,
          colorNeutral,
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color.withOpacity(0.7)),
          const Spacer(),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

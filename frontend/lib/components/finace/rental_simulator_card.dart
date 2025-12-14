import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';

class RentalSimulatorCard extends StatelessWidget {
  final double aluguelSimulado;
  final double mediaMercado;
  final double maxSliderValue;
  final Function(double) onAluguelChanged;
  final double opexMensal;
  final double noiMensal;

  const RentalSimulatorCard({
    super.key,
    required this.aluguelSimulado,
    required this.mediaMercado,
    required this.maxSliderValue,
    required this.onAluguelChanged,
    required this.opexMensal,
    required this.noiMensal,
  });

  @override
  Widget build(BuildContext context) {
    double pctDiff = 0;
    if (mediaMercado > 0) {
      pctDiff = ((aluguelSimulado - mediaMercado) / mediaMercado);
    }

    final colorProfit = Colors.green.shade700;
    final colorLoss = Colors.red.shade400;
    final barColor = pctDiff > 0.2
        ? Colors.red
        : (pctDiff < -0.2 ? Colors.orange : Colors.green);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Renda Bruta (Aluguel)",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                AppFormatters.formatCurrency(aluguelSimulado),
                style: TextStyle(
                  color: colorProfit,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primary,
              trackHeight: 4.0,
            ),
            child: Slider(
              value: aluguelSimulado,
              min: 0,
              max: maxSliderValue,
              activeColor: colorProfit,
              onChanged: onAluguelChanged,
            ),
          ),

          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Média da Região (IA):",
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    Text(
                      AppFormatters.formatCurrency(mediaMercado),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: pctDiff > 0.1
                            ? Colors.red[50]
                            : (pctDiff < -0.1
                                  ? Colors.green[50]
                                  : Colors.blue[50]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        pctDiff > 0.1
                            ? "Acima"
                            : (pctDiff < -0.1 ? "Oportunidade" : "Na Média"),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: barColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Despesas Operacionais",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: "IPTU + Condomínio + Taxas",
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                Text(
                  "- ${AppFormatters.formatCurrency(opexMensal)}",
                  style: TextStyle(
                    color: colorLoss,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: noiMensal >= 0
                  ? colorProfit.withOpacity(0.1)
                  : colorLoss.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Resultado Líquido (Mês)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  AppFormatters.formatCurrency(noiMensal),
                  style: TextStyle(
                    color: noiMensal >= 0 ? colorProfit : colorLoss,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

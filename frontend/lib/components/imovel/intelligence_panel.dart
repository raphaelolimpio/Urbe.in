import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../primary_button.dart';

class IntelligencePanel extends StatelessWidget {
  final Map<String, dynamic>? resultado;
  final double raioSelecionado;
  final Function(double) onRaioChanged;
  final VoidCallback onActionPressed;
  final bool isLoading;

  const IntelligencePanel({
    super.key,
    required this.resultado,
    required this.raioSelecionado,
    required this.onRaioChanged,
    required this.onActionPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Urbe Intelligence",
          style: AppTextStyles.headingSmall.copyWith(
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (resultado != null) _buildResultContent(),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.vertical(
                    top: resultado == null
                        ? const Radius.circular(16)
                        : Radius.zero,
                    bottom: const Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    if (resultado == null)
                      Text(
                        "Analise o potencial deste ponto baseado em dados reais do entorno.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    if (resultado == null) const SizedBox(height: 20),

                    Row(
                      children: [
                        Text(
                          "Raio: ${raioSelecionado.toInt()}m",
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: raioSelecionado,
                            min: 100,
                            max: 2000,
                            divisions: 19,
                            activeColor: AppColors.primary,
                            onChanged: onRaioChanged,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    PrimaryButton(
                      text: resultado == null
                          ? "RODAR ANÁLISE"
                          : "ATUALIZAR DADOS",
                      onPressed: onActionPressed,
                      isLoading: isLoading,
                      icon: resultado == null
                          ? Icons.auto_awesome
                          : Icons.refresh,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            "VOCAÇÃO SUGERIDA",
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resultado!['setor_sugerido'] ?? 'Indefinido',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingBig.copyWith(
              fontSize: 26,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resultado!['nicho_especifico'] ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _miniMetric(
                  "Risco",
                  resultado!['grau_risco'],
                  AppColors.riskMedium,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _miniMetric(
                  "Potencial",
                  resultado!['potencial_retorno'],
                  AppColors.potentialHigh,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String? value, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? 'N/A',
          style: AppTextStyles.titleList.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

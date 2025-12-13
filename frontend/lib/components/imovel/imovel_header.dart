import 'package:flutter/material.dart';
import '../../models/imovel_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_formatters.dart';

class ImovelHeader extends StatelessWidget {
  final Imovel imovel;

  const ImovelHeader({super.key, required this.imovel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          imovel.titulo,
          style: AppTextStyles.titleList.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                imovel.enderecoCompleto,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Valor de Venda", style: AppTextStyles.caption),
                Text(
                  AppFormatters.formatCurrency(imovel.valorCompra),
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.square_foot,
                    size: 20,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppFormatters.formatArea(imovel.areaM2),
                    style: AppTextStyles.titleList,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

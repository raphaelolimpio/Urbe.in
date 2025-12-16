import 'package:flutter/material.dart';
import '../models/imovel_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ImovelCard extends StatelessWidget {
  final Imovel imovel;
  final VoidCallback onTap;

  const ImovelCard({super.key, required this.imovel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isLocado = imovel.statusOcupacao == 'locado';
    final Color statusColor = isLocado ? Colors.green : Colors.red;
    final String statusText = (imovel.statusOcupacao ?? 'Indefinido').toUpperCase();
    final IconData statusIcon = isLocado ? Icons.check_circle : Icons.error_outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.business, color: AppColors.primary),
        ),
        
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(imovel.titulo, style: AppTextStyles.titleList),
            const SizedBox(height: 6),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor, width: 0.5), 
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
        
        subtitle: Text(
          imovel.enderecoCompleto,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
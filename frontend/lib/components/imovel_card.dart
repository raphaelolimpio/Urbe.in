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
        title: Text(imovel.titulo, style: AppTextStyles.titleList),
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
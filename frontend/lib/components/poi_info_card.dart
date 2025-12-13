import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class PoiInfoCard extends StatelessWidget {
  final Map<String, dynamic> poi;
  final VoidCallback onClose;

  const PoiInfoCard({
    super.key,
    required this.poi,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {

    final nome = (poi['nome'] ?? 'Local Desconhecido').toString();
    final tipo = (poi['tipo'] ?? '').toString();
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ícone Grande
            _buildIcon(tipo),
            const SizedBox(width: 12),
            
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nome,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Categoria: ${tipo.toUpperCase()}",
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            
            // Botão Fechar
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.grey),
              onPressed: onClose,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String tipo) {
    IconData icone = Icons.place;
    Color cor = Colors.grey;
    String t = tipo.toLowerCase();

    if (t.contains('restaurant') || t.contains('cafe') || t.contains('bar')) {
       icone = Icons.restaurant; cor = Colors.orange;
    } else if (t.contains('school') || t.contains('university')) {
       icone = Icons.school; cor = Colors.blue;
    } else if (t.contains('hospital') || t.contains('clinic')) {
       icone = Icons.local_hospital; cor = Colors.redAccent;
    } else if (t.contains('gym')) {
       icone = Icons.fitness_center; cor = Colors.purple;
    } else if (t.contains('clothes') || t.contains('fashion') || t == 'moda') {
       icone = Icons.checkroom; cor = Colors.pinkAccent; 
    } else if (t.contains('shop') || t.contains('market') || t.contains('mall')) {
       icone = Icons.shopping_bag; cor = AppColors.primary;
    } else if (t.contains('office') || t.contains('corporativo')) {
       icone = Icons.business; cor = Colors.indigo;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        shape: BoxShape.circle,
        // Sem borda no card para ficar mais clean
      ),
      child: Icon(icone, color: cor, size: 24),
    );
  }
}
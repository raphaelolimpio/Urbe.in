import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart'; 

class StrategyCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StrategyCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.headingSmall.copyWith(color: color.withOpacity(0.8)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleList.copyWith(color: color), 
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MapFilterBar extends StatelessWidget {
  final List<String> categorias;
  final Set<String> filtrosAtivos;
  final Function(String, bool) onFilterChanged;

  const MapFilterBar({
    super.key,
    required this.categorias,
    required this.filtrosAtivos,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categorias.map((cat) {
          final bool isSelected = filtrosAtivos.contains(cat);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(
                cat, 
                style: TextStyle(
                  fontSize: 10, 
                  color: isSelected ? Colors.white : Colors.black87
                )
              ),
              selected: isSelected,
              onSelected: (bool selected) => onFilterChanged(cat, selected),
              backgroundColor: Colors.white.withOpacity(0.9),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }
}
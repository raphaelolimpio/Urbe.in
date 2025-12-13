import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PoiUtils {
  static String getCategoria(String? tipo) {
    if (tipo == null) return "Outros";
    String t = tipo.toLowerCase();
    
    if (t.contains('restaurant') || t.contains('cafe') || t.contains('bar')) return "Gastronomia";
    if (t.contains('school') || t.contains('university')) return "Educação";
    if (t.contains('hospital') || t.contains('clinic')) return "Saúde";
    if (t.contains('clothes') || t.contains('fashion') || t == 'moda') return "Moda";
    if (t.contains('shop') || t.contains('market') || t.contains('mall')) return "Mercado";
    if (t.contains('gym') || t.contains('fitness')) return "Lazer";
    if (t.contains('office') || t.contains('corporativo')) return "Corporativo";
    
    return "Outros";
  }
  static (IconData, Color) getVisuals(String? tipo) {
    String t = (tipo ?? '').toLowerCase();
    
    if (t.contains('restaurant') || t.contains('cafe') || t.contains('bar')) {
       return (Icons.restaurant, Colors.orange);
    } else if (t.contains('school') || t.contains('university')) {
       return (Icons.school, Colors.blue);
    } else if (t.contains('hospital') || t.contains('clinic')) {
       return (Icons.local_hospital, Colors.redAccent);
    } else if (t.contains('gym')) {
       return (Icons.fitness_center, Colors.purple);
    } else if (t.contains('clothes') || t.contains('fashion') || t == 'moda') {
       return (Icons.checkroom, Colors.pinkAccent);
    } else if (t.contains('shop') || t.contains('market') || t.contains('mall')) {
       return (Icons.shopping_bag, AppColors.primary);
    } else if (t.contains('office') || t.contains('corporativo')) {
       return (Icons.business, Colors.indigo);
    }
    
    return (Icons.place, Colors.grey);
  }
}
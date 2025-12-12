import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  
  // Ex: "Urbe.in", "Vocação Sugerida"
  static final TextStyle headingBig = GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Ex: "Gastronomia / Lazer" (Resultado da IA)
  static final TextStyle headingMedium = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Ex: Títulos dos Cards ("GRAU DE RISCO")
  static final TextStyle headingSmall = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // --- CORPO E LEITURA (Inter) ---

  // Ex: Texto padrão, endereços
  static final TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  // Ex: Legendas, textos secundários ("m2", labels)
  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // Ex: Valores monetários, Títulos de Imóveis na lista
  static final TextStyle titleList = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Ex: Texto de Botões
  static final TextStyle buttonText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    letterSpacing: 0.5,
  );
}
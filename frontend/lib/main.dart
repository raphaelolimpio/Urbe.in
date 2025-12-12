import 'package:flutter/material.dart';
import 'package:frontend/screens/cadastro_investidor_screen.dart';
import 'package:frontend/screens/dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';


void main() {
  runApp(const UrbeApp());
}

class UrbeApp extends StatelessWidget {
  const UrbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urbe.in',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C853),
          secondary: const Color(0xFF212121),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      // Aqui trocamos o Scaffold provisório pela nossa tela real
      home: const DashboardScreen(), 
    );
  }
}
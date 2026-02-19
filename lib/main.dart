import 'package:flutter/material.dart';
import 'pages/auth/login_page.dart';

void main() {
  runApp(const PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager Sicuro',
      debugShowCheckedModeBanner: false,
      theme: _buildModernTheme(),
      home: const LoginPage(),
    );
  }

  // Tema moderno e scuro
  ThemeData _buildModernTheme() {
    final base = ThemeData.dark();

    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF1E88E5), // Blu Profondo
        secondary: const Color(0xFF00C853), // Verde Accesso (Accento)
        surface: const Color(0xFF2C2C2C), // Sfondo per Card/Campi
        background: const Color(0xFF121212), // Sfondo Principale
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E88E5),
        titleTextStyle: base.textTheme.headlineMedium
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData( // <--- Usa CardThemeData()
        color: const Color(0xFF1E1E1E), // Colore Card
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: Color(0xFF1E88E5)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853), // Verde per i pulsanti principali
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00C853),
        foregroundColor: Colors.black,
      ),
    );
  }
}

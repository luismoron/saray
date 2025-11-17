import 'package:flutter/material.dart';

class AppTheme {
  // Definición de los colores exactos de tu paleta
  static const Color _lightWhite = Color(0xFFF9F7F7); // #F9F7F7
  static const Color _softBlue = Color(0xFFDBE2EF);   // #DBE2EF
  static const Color _primaryBlue = Color(0xFF3F72AF); // #3F72AF
  static const Color _darkNavy = Color(0xFF112D4E);   // #112D4E

  // --- MODO CLARO (Light Mode) ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightWhite, // Fondo general claro
    
    colorScheme: const ColorScheme.light(
      primary: _primaryBlue,       // Botones y elementos activos
      onPrimary: _lightWhite,      // Texto sobre el botón primario
      secondary: _darkNavy,        // Elementos de acento
      onSecondary: _lightWhite,
      surface: _softBlue,          // Color de tarjetas (Cards)
      onSurface: _darkNavy,        // Texto sobre tarjetas
      surfaceContainer: _lightWhite, // Superficies base
      error: Colors.redAccent,
      onSurfaceVariant: _darkNavy, // Texto secundario
    ),

    // Personalización extra para AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryBlue,
      foregroundColor: _lightWhite,
      elevation: 0,
    ),
    
    // Personalización de Tarjetas
    cardTheme: const CardTheme(
      color: _softBlue,
      elevation: 2,
    ),
  );

  // --- MODO OSCURO (Dark Mode) ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkNavy, // Fondo general oscuro
    
    colorScheme: const ColorScheme.dark(
      primary: _primaryBlue,       // Mantenemos la identidad de marca
      onPrimary: _lightWhite,      // Texto sobre botón
      secondary: _softBlue,        // Acento más suave en modo oscuro
      onSecondary: _darkNavy,
      surface: _darkNavy,          // Las tarjetas se funden o son un tono más claro
      onSurface: _lightWhite,      // Texto principal claro
      surfaceContainer: Color(0xFF1B3A5F), // Un tono ligeramente más claro que el fondo para distinguir tarjetas (opcional)
      error: Colors.redAccent,
    ),

    // Personalización extra para AppBar en Dark Mode
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkNavy, // Se funde con el fondo
      foregroundColor: _lightWhite,
      elevation: 0,
    ),
    
    // Personalización de botones para que resalten en oscuro
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,
        foregroundColor: _lightWhite,
      ),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:password_strength/password_strength.dart';

// Enum per definire i livelli di forza della password
enum PasswordStrengthLevel {
  blank,
  weak,
  medium,
  strong,
  veryStrong,
}

// Modello per una singola voce di password
class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String email;
  final String password;
  final String colorHex; // Codice colore esadecimale (es. #FF0000)

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.email,
    required this.password,
    this.colorHex = '#CCCCCC', // Valore di default grigio chiaro
  });
  
  // Metodo per convertire colorHex in un oggetto Color di Flutter
  Color get color {
    final hexString = colorHex.replaceFirst('#', '');
    if (hexString.length == 6) {
      return Color(int.parse('FF$hexString', radix: 16));
    }
    // Ritorna il colore di default se il formato è sbagliato
    return Colors.grey.shade400; 
  }

  // Metodo statico per calcolare il valore di forza (0.0 a 1.0)
  static double getStrength(String password) {
    if (password.isEmpty) return 0.0;
    return estimatePasswordStrength(password); 
  }
  
  // NUOVO GETTER: Restituisce il valore di forza (double) per la progress bar
  double get strengthValue => getStrength(password);

  // Metodo per ottenere l'oggetto PasswordStrengthLevel
  PasswordStrengthLevel get strengthLevel {
    final double strength = strengthValue; // Usa il nuovo getter

    if (password.isEmpty) {
      return PasswordStrengthLevel.blank;
    } else if (strength < 0.3) {
      return PasswordStrengthLevel.weak;
    } else if (strength < 0.5) {
      return PasswordStrengthLevel.medium;
    } else if (strength < 0.75) {
      return PasswordStrengthLevel.strong;
    } else {
      return PasswordStrengthLevel.veryStrong;
    }
  }
  
  // Metodo per ottenere il colore associato al livello di forza
  Color strengthColor(ThemeData theme) {
    switch (strengthLevel) {
      case PasswordStrengthLevel.weak:
        return Colors.red;
      case PasswordStrengthLevel.medium:
        return Colors.orange;
      case PasswordStrengthLevel.strong:
        return Colors.lightGreen;
      case PasswordStrengthLevel.veryStrong:
        return theme.colorScheme.primary; // Colore del tema
      case PasswordStrengthLevel.blank:
      default:
        return theme.dividerColor;
    }
  }

  // 4. METODO toMap() (Serializzazione)
  Map<String, String> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'email': email,
      'password': password,
      'colorHex': colorHex, // <--- Aggiornato
    };
  }

  // 5. METODO fromMap() (Deserializzazione)
  static PasswordEntry fromMap(Map<String, String> map) {
    return PasswordEntry(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Sconosciuto',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      colorHex: map['colorHex'] ?? '#CCCCCC', // <--- Aggiornato
    );
  }
}

import 'package:flutter/material.dart'; // Importato per usare Color
import 'package:password_strength/password_strength.dart'; // <--- Importa la libreria

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

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.email,
    required this.password,
  });

  // ----------------------------------------------------
  // --- LOGICA FORZA PASSWORD (Aggiunta per PasswordCard) ---
  // ----------------------------------------------------

  // 1. Metodo statico per calcolare il livello di forza (0.0 a 1.0)
  static double getStrength(String password) {
    if (password.isEmpty) return 0.0;
    // Utilizza la funzione get di 'password_strength'
    return estimatePasswordStrength(password); 
  }

  // 2. Getter per ottenere l'oggetto PasswordStrengthLevel
  PasswordStrengthLevel get strengthLevel {
    final double strength = getStrength(password);

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
  
  // 3. Getter che restituisce il valore (0.0 a 1.0) per LinearProgressIndicator
  double get strengthValue {
    if (password.isEmpty) return 0.0;
    return getStrength(password);
  }

  // 4. Metodo che restituisce il Colore in base al livello di forza
  Color strengthColor(ThemeData theme) {
    switch (strengthLevel) {
      case PasswordStrengthLevel.weak:
        return Colors.red;
      case PasswordStrengthLevel.medium:
        return Colors.orange;
      case PasswordStrengthLevel.strong:
        return Colors.blue;
      case PasswordStrengthLevel.veryStrong:
        return Colors.green;
      case PasswordStrengthLevel.blank:
      default:
        return theme.dividerColor;
    }
  }


  // ----------------------------------------------------
  // --- SERIALIZZAZIONE (Invariata) ---
  // ----------------------------------------------------
  
  // 5. METODO toMap() (Serializzazione)
  Map<String, String> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  // 6. METODO fromMap() (Deserializzazione)
  static PasswordEntry fromMap(Map<String, String> map) {
    return PasswordEntry(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Sconosciuto',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }
}

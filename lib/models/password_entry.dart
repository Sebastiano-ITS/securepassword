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
  
  // Metodo statico per calcolare il livello di forza (0.0 a 1.0)
  static double getStrength(String password) {
    if (password.isEmpty) return 0.0;
    // Utilizza la funzione get
    return estimatePasswordStrength(password); 
  }

  // Metodo per ottenere l'oggetto PasswordStrengthLevel
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

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.email,
    required this.password,
  });

  // 4. METODO toMap() (Serializzazione)
  Map<String, String> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'email': email,
      'password': password,
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
    );
  }
}
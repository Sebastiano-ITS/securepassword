import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/password_entry.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // Chiavi per l'account Master dell'App
  static const String _masterKey = 'master_password';
  static const String _usernameKey = 'master_username';
  static const String _emailKey = 'master_email'; // <--- NUOVA CHIAVE PER EMAIL
  static const String _sessionKey = 'is_logged_in'; 
  
  // Chiave per le password salvate nel vault
  static const String _passwordsListKey = 'password_list';

  // ------------------------------------
  // --- Gestione Master Account e Sessione ---\r
  // ------------------------------------\r

  // NUOVO: Metodo per recuperare l'username salvato
  Future<String?> getMasterUsername() async {
    return await _storage.read(key: _usernameKey);
  }
  
  // NUOVO: Metodo per recuperare l'email salvata
  Future<String?> getMasterEmail() async {
    return await _storage.read(key: _emailKey);
  }

  // Controlla se le credenziali master sono già state salvate (Account creato)
  Future<bool> isAccountCreated() async {
    return await _storage.containsKey(key: _masterKey);
  }
  
  // Imposta l'account master al momento della registrazione
  Future<void> createMasterAccount({
    required String username,
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _masterKey, value: password);
    await _setSession(true); // Logga automaticamente dopo la registrazione
  }

  // Imposta lo stato di sessione (per rimanere loggato)
  Future<void> _setSession(bool isLoggedIn) async {
    await _storage.write(key: _sessionKey, value: isLoggedIn.toString());
  }

  // Controlla se l'utente è già loggato (Persistenza Sessione)
  Future<bool> checkSession() async {
    final sessionValue = await _storage.read(key: _sessionKey);
    return sessionValue == 'true';
  }

  // Logica di Login
  Future<bool> login(String username, String password) async {
    final storedUsername = await _storage.read(key: _usernameKey);
    final storedPassword = await _storage.read(key: _masterKey);

    if (storedUsername == username && storedPassword == password) {
      await _setSession(true);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _setSession(false); // Termina la sessione
  }

  // ------------------------------------\r
  // --- Gestione Password Vault (Invariato) ---\r
  // ------------------------------------\r

  Future<List<PasswordEntry>> loadPasswords() async {
    final jsonString = await _storage.read(key: _passwordsListKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => PasswordEntry.fromMap(Map<String, String>.from(json)))
        .toList();
  }

  Future<void> _savePasswords(List<PasswordEntry> passwords) async {
    final jsonString = jsonEncode(passwords.map((p) => p.toMap()).toList());
    await _storage.write(key: _passwordsListKey, value: jsonString);
  }

  Future<void> addPassword(PasswordEntry entry) async {
    final passwords = await loadPasswords();
    
    // 1. Aggiungi la nuova entry
    passwords.add(entry); 
    
    // 2. SALVA LA LISTA AGGIORNATA
    await _savePasswords(passwords); 
  }

  Future<void> deletePassword(String id) async {
    final passwords = await loadPasswords();
    
    // 1. Rimuovi la password con l'ID specificato
    passwords.removeWhere((p) => p.id == id);
    
    // 2. SALVA LA LISTA AGGIORNATA
    await _savePasswords(passwords);
  }
}

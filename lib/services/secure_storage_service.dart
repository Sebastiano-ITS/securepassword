// lib/services/secure_storage_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/password_entry.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // Chiavi per l'account Master dell'App
  static const String _masterKey = 'master_password';
  static const String _usernameKey = 'master_username';
  static const String _sessionKey = 'is_logged_in'; 
  
  // Chiave per le password salvate nel vault
  static const String _passwordsListKey = 'password_list';

  // ------------------------------------
  // --- Gestione Master Account e Sessione ---
  // ------------------------------------

  // Metodo per recuperare l'username salvato
  Future<String?> getMasterUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  // Metodo per recuperare l'email master (usiamo la stessa chiave dell'username per ora)
  Future<String?> getMasterEmail() async {
    return await _storage.read(key: _usernameKey);
  }

  // Controlla se le credenziali master sono già state salvate (Account creato)
  Future<bool> isAccountCreated() async {
    return await _storage.containsKey(key: _masterKey);
  }

  // Imposta lo stato di sessione (per rimanere loggato)
  Future<void> _setSession(bool isLoggedIn) async {
    await _storage.write(key: _sessionKey, value: isLoggedIn.toString());
  }

  // Controlla se l'utente è già loggato
  // Questo corrisponde all'errore: 'checkSession' -> is_logged_in
  Future<bool> isLoggedIn() async {
    final status = await _storage.read(key: _sessionKey);
    return status == 'true';
  }

  // Registra un nuovo account Master
  // Questo corrisponde all'errore: 'createMasterAccount' -> registerMasterAccount
  Future<void> registerMasterAccount(String username, String password) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _masterKey, value: password);
    await _setSession(true);
  }

  // Autentica l'utente Master
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

  // ------------------------------------
  // --- Gestione Password Vault ---
  // ------------------------------------

  // Carica tutte le password
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

  // Salva l'intera lista di password (privato)
  Future<void> _savePasswords(List<PasswordEntry> passwords) async {
    final jsonString = jsonEncode(passwords.map((p) => p.toMap()).toList());
    await _storage.write(key: _passwordsListKey, value: jsonString);
  }

  // AGGIUNGI NUOVA PASSWORD
  Future<void> addPassword(PasswordEntry entry) async {
    final passwords = await loadPasswords();
    passwords.add(entry); 
    await _savePasswords(passwords); 
  }

  // AGGIORNA PASSWORD ESISTENTE
  Future<void> updatePassword(PasswordEntry entry) async {
    final passwords = await loadPasswords();
    
    // Trova l'indice della vecchia entry (usando l'ID)
    final index = passwords.indexWhere((p) => p.id == entry.id);
    
    if (index != -1) {
      // Sostituisce la vecchia entry con la nuova entry aggiornata
      passwords[index] = entry; 
      await _savePasswords(passwords); 
    }
  }

  // ELIMINA PASSWORD
  Future<void> deletePassword(String id) async {
    final passwords = await loadPasswords();
    
    // Rimuove la password con l'ID specificato
    passwords.removeWhere((p) => p.id == id);
    
    await _savePasswords(passwords);
  }
}

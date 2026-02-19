import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/password_entry.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // Chiavi per l'account Master dell'App
  static const String _masterKey = 'master_password';
  static const String _usernameKey = 'master_username';
  // NUOVA CHIAVE PER L'EMAIL
  static const String _masterEmailKey = 'master_email'; 
  static const String _sessionKey = 'is_logged_in'; 
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  // Chiave per le password salvate nel vault
  static const String _passwordsListKey = 'password_list';

  // ------------------------------------
  // --- Gestione Master Account e Sessione ---
  // ------------------------------------

  // Metodo per creare (registrare) l'account Master
  Future<void> createMasterAccount(String username, String password, String email) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _masterKey, value: password);
    await _storage.write(key: _masterEmailKey, value: email);
    await _setSession(true);
  }

  // Metodo per recuperare l'username salvato
  Future<String?> getMasterUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  // NUOVO: Metodo per recuperare l'email salvata
  Future<String?> getMasterEmail() async {
    return await _storage.read(key: _masterEmailKey);
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
  Future<bool> isLoggedIn() async {
    final sessionValue = await _storage.read(key: _sessionKey);
    return sessionValue == 'true';
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _setSession(isLoggedIn);
  }

  // Logica di Login: verifica le credenziali e imposta la sessione
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

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  // ------------------------------------
  // --- Gestione Password Vault (Invariato) ---
  // ------------------------------------

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

  // AGGIUNGI NUOVA PASSWORD
  Future<void> addPassword(PasswordEntry entry) async {
    final passwords = await loadPasswords();
    passwords.add(entry); 
    await _savePasswords(passwords); 
  }

  // ELIMINA PASSWORD
  Future<void> deletePassword(String id) async {
    final passwords = await loadPasswords();
    passwords.removeWhere((p) => p.id == id);
    await _savePasswords(passwords);
  }

  // MODIFICA PASSWORD
  Future<void> updatePassword(PasswordEntry updatedEntry) async {
    final passwords = await loadPasswords();
    final index = passwords.indexWhere((p) => p.id == updatedEntry.id);

    if (index != -1) {
      passwords[index] = updatedEntry;
      await _savePasswords(passwords);
    }
  }

  // NUOVO: Metodo per aggiornare solo l'email del Master Account
  Future<void> updateMasterEmail(String newEmail) async {
    await _storage.write(key: _masterEmailKey, value: newEmail);
  }

}

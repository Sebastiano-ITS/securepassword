import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SecureStorageService _storageService = SecureStorageService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoginMode = true; // true: Login, false: Registrazione
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPasswordVisible = false; // Stato per la visibilità della password

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  // Controlla se un account Master è già stato creato e se la sessione è attiva
  Future<void> _checkInitialState() async {
    // 1. Controlla se esiste l'account (determina la modalità Login/Registrazione)
    final accountExists = await _storageService.isAccountCreated();
    
    // 2. Controlla se l'utente è già loggato
    // Correzione: uso isLoggedIn() invece di checkSession()
    final sessionActive = await _storageService.isLoggedIn();

    if (sessionActive && mounted) {
      // Se la sessione è attiva, naviga direttamente alla HomePage
      _navigateToHome();
      return; 
    }

    setState(() {
      _isLoginMode = accountExists; // Se esiste, la modalità predefinita è Login
      _isLoading = false;
    });
  }
  
  void _navigateToHome() {
     Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (Route<dynamic> route) => false,
      );
  }

  void _handleAuth() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty || password.length < 6) {
      setState(() {
        _errorMessage = 'Username e password (min. 6 caratteri) sono obbligatori.';
        _isLoading = false;
      });
      return;
    }
    
    bool success = false;
    String successMessage = '';

    try {
      if (_isLoginMode) {
        // Modalità Login: usa il metodo 'login'
        success = await _storageService.login(username, password);
        successMessage = 'Accesso effettuato con successo!';
      } else {
        // Modalità Registrazione: usa il metodo 'registerMasterAccount'
        // Correzione: uso registerMasterAccount() invece di createMasterAccount()
        await _storageService.registerMasterAccount(username, password);
        success = true;
        successMessage = 'Account Master creato con successo!';
      }
    } catch (e) {
      success = false;
      _errorMessage = 'Errore di autenticazione: ${e.toString()}';
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
      _navigateToHome();
    } else {
      setState(() {
        _isLoading = false;
        // Mostra un messaggio di errore più specifico per il login fallito
        if (_isLoginMode && _errorMessage == null) {
          _errorMessage = 'Credenziali non valide. Riprova.';
        }
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = _isLoginMode ? 'ACCEDI' : 'REGISTRATI';
    final toggleText = _isLoginMode
        ? 'Non hai un account? Registrati ora'
        : 'Hai già un account? Accedi';

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo/Titolo
              Icon(
                Icons.lock_open_rounded, 
                size: 100, 
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                _isLoginMode ? 'Bentornato nel tuo Vault' : 'Crea il tuo Vault Master',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 40),

              // Campo Username/Identificativo
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username o Email Master',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                keyboardType: TextInputType.emailAddress,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),

              // Campo Password
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password Master',
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                style: theme.textTheme.bodyLarge,
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),

              // Pulsante principale Login/Registrati
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: theme.colorScheme.secondary),
                    )
                  : ElevatedButton(
                      onPressed: _handleAuth,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        elevation: 5,
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
              const SizedBox(height: 20),

              // Pulsante per cambiare modalità
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  toggleText,
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final sessionActive = await _storageService.isLoggedIn();

    if (sessionActive && mounted) {
      // Se la sessione è attiva, vai direttamente alla Home Page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // Altrimenti, imposta la modalità iniziale e nascondi il loading
      setState(() {
        _isLoginMode = accountExists; // Se esiste, la modalità predefinita è Login
        _isLoading = false;
      });
    }
  }

  void _handleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Compila tutti i campi.';
        _isLoading = false;
      });
      return;
    }

    bool success = false;
    String successMessage = '';

    try {
      if (_isLoginMode) {
        // Modalità Login
        success = await _storageService.login(username, password);
        if (!success) {
          _errorMessage = 'Username o Password errati.';
        } else {
          successMessage = 'Accesso effettuato con successo!';
        }
      } else {
        // Modalità Registrazione (Sign Up)
        // CORREZIONE: Cambia 'registerMasterAccount' con 'createMasterAccount'
        await _storageService.createMasterAccount(username, password); 
        success = true;
        successMessage = 'Account Master creato con successo!';
      }
    } catch (e) {
      _errorMessage = 'Errore di autenticazione: $e';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      if (success) {
        // Mostra un messaggio di successo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        // Naviga alla Home Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else if (_errorMessage != null) {
        // Mostra il messaggio di errore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
    }
  }
  
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null; // Resetta gli errori
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final buttonText = _isLoginMode ? 'ACCEDI AL VAULT' : 'REGISTRATI';
    final toggleText = _isLoginMode ? 'Non hai un account? Registrati' : 'Hai già un account? Accedi';
    final headerText = _isLoginMode ? 'Bentornato!' : 'Crea il tuo Account Master';
    final subHeaderText = _isLoginMode 
        ? 'Inserisci le credenziali per sbloccare il tuo Secure Vault.'
        : 'Questo account proteggerà tutte le tue password. Scegli una password forte!';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Vault'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                _isLoginMode ? Icons.lock_open_rounded : Icons.person_add_alt_1_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              
              Text(
                headerText,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subHeaderText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),

              // Campo Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username Master',
                  prefixIcon: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Campo Password
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Master Password',
                  prefixIcon: Icon(Icons.lock_rounded, color: theme.colorScheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
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

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
  
  // Controller esistenti
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // NUOVI Controller per Registrazione
  final TextEditingController _emailController = TextEditingController(); // <--- NUOVO
  final TextEditingController _confirmPasswordController = TextEditingController(); // <--- NUOVO
  
  bool _isLoginMode = true; // true: Login, false: Signup
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  // Controlla se un account Master è già stato creato E se c'è una sessione attiva
  Future<void> _checkInitialState() async {
    final accountExists = await _storageService.isAccountCreated();
    final sessionActive = await _storageService.checkSession(); // <--- CONTROLLO SESSIONE
    
    if (sessionActive) {
      // Se la sessione è attiva, naviga direttamente alla HomePage
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
      return;
    }
    
    setState(() {
      _isLoginMode = accountExists; // Se esiste, la modalità predefinita è Login
      _isLoading = false;
    });
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
        _errorMessage = 'Nome utente e password non possono essere vuoti.';
        _isLoading = false;
      });
      return;
    }

    bool success = false;

    if (_isLoginMode) {
      // LOGICA DI LOGIN
      success = await _storageService.login(username, password);
      if (!success) {
        _errorMessage = 'Credenziali non valide.';
      }
    } else {
      // LOGICA DI REGISTRAZIONE (SIGNUP)
      final email = _emailController.text.trim();
      final confirmPassword = _confirmPasswordController.text;
      
      if (email.isEmpty || password != confirmPassword) {
        _errorMessage = email.isEmpty 
            ? 'L\'email non può essere vuota.'
            : 'Le password non corrispondono.';
      } else {
        await _storageService.createMasterAccount(
          username: username,
          email: email,
          password: password,
        );
        success = true;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Naviga alla homepage e rimuove la pagina di autenticazione
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      // Pulisci i campi aggiuntivi quando si cambia modalità
      _emailController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Testi dinamici
    final title = _isLoginMode ? 'Accedi al tuo Vault' : 'Registra Account Master';
    final buttonText = _isLoginMode ? 'ACCEDI' : 'REGISTRATI';
    final toggleText = _isLoginMode
        ? 'Non hai un account? Registrati ora.'
        : 'Hai già un account? Accedi.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Immagine/Icona
              Icon(
                Icons.security_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 30),
              
              // Campo Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Utente Master',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Email (Solo in modalità Registrazione)
              if (!_isLoginMode) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Master',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Campo Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Master',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo Conferma Password (Solo in modalità Registrazione)
              if (!_isLoginMode) ...[
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Conferma Password Master',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Messaggio di Errore
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),
              
              // Pulsante principale Login/Registrati
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleAuth,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
              const SizedBox(height: 20),
              
              // Pulsante per cambiare modalità
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  toggleText,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

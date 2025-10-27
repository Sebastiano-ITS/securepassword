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
  
  bool _isLoginMode = true; // true: Login, false: Signup
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  // Controlla se un account Master è già stato creato al primo avvio
  Future<void> _checkInitialState() async {
    final accountExists = await _storageService.isAccountCreated();
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
        _errorMessage = "Compila tutti i campi.";
        _isLoading = false;
      });
      return;
    }

    bool success = false;

    if (_isLoginMode) {
      // Modalità Login
      success = await _storageService.login(username, password);
      if (!success) {
        setState(() => _errorMessage = "Credenziali errate.");
      }
    } else {
      // Modalità Registrazione (Signup)
      await _storageService.signUp(username, password);
      success = true; 
    }

    if (success) {
      _navigateToHome();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
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
    final String mainTitle = _isLoginMode ? 'Master Login' : 'Master Registrazione';
    final String buttonText = _isLoginMode ? 'ACCEDI' : 'REGISTRATI';
    final String toggleText = _isLoginMode 
        ? 'Non hai un account Master? Registrati' 
        : 'Hai già un account Master? Accedi';

    return Scaffold(
      appBar: AppBar(
        title: Text(mainTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                mainTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              // Campo Username
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Username o Email',
                  hintText: 'Master Account Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 20),
              // Campo Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Master Password',
                  hintText: 'Inserisci la Master Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_rounded),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
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
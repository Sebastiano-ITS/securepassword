import 'package:flutter/material.dart';
import '../../services/secure_storage_service.dart';
import '../home_page.dart';
import 'signup_page.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SecureStorageService _storageService = SecureStorageService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isLoading = true;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _biometricEnabled = false;
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final sessionActive = await _storageService.isLoggedIn();
    _biometricEnabled = await _storageService.isBiometricEnabled();
    _canUseBiometrics = await _localAuth.isDeviceSupported() || await _localAuth.canCheckBiometrics;

    if (!_biometricEnabled && sessionActive && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      return;
    }

    if (_biometricEnabled && _canUseBiometrics) {
      try {
        final didAuth = await _localAuth.authenticate(
          localizedReason: 'Autenticati per accedere',
          options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
        );
        if (didAuth && mounted) {
          await _storageService.setLoggedIn(true);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
          return;
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _tryBiometricLogin() async {
    try {
      if (!(_biometricEnabled && _canUseBiometrics)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometria non disponibile.')));
        return;
      }
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Autenticati per accedere',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (didAuth && mounted) {
        await _storageService.setLoggedIn(true);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Autenticazione fallita: $e')));
    }
  }

  void _handleLogin() async {
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

    try {
      success = await _storageService.login(username, password);
      if (!success) {
        _errorMessage = 'Username o Password errati.';
      }
    } catch (e) {
      _errorMessage = 'Errore di autenticazione: $e';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accesso effettuato con successo!')));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      } else if (_errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Icon(Icons.lock_open_rounded, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text('Bentornato!', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Inserisci le credenziali per sbloccare il tuo Secure Vault.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username Master',
                  prefixIcon: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Master Password',
                  prefixIcon: Icon(Icons.lock_rounded, color: theme.colorScheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
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
                  child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              const SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary))
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        elevation: 5,
                      ),
                      child: const Text('ACCEDI AL VAULT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
              const SizedBox(height: 12),
              if (_biometricEnabled && _canUseBiometrics)
                ElevatedButton.icon(
                  onPressed: _tryBiometricLogin,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Accedi con impronta'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignupPage()));
                },
                child: Text('Non hai un account? Registrati', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

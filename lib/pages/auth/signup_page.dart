import 'package:flutter/material.dart';
import '../../services/secure_storage_service.dart';
import '../home_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final SecureStorageService _storageService = SecureStorageService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  void _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() {
        _errorMessage = 'Compila tutti i campi.';
        _isLoading = false;
      });
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Email non valida.';
        _isLoading = false;
      });
      return;
    }

    final lengthOk = password.length >= 8;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    if (!(lengthOk && hasUpper && hasLower && hasDigit)) {
      setState(() {
        _errorMessage = 'La password deve avere almeno 8 caratteri, una maiuscola, una minuscola e un numero.';
        _isLoading = false;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _errorMessage = 'Le password non coincidono.';
        _isLoading = false;
      });
      return;
    }

    try {
      await _storageService.createMasterAccount(username, password, email);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Master creato con successo!')));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore di registrazione: $e';
      });
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
              Icon(Icons.person_add_alt_1_rounded, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text('Crea il tuo Account Master', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Questo account proteggerà tutte le tue password. Scegli una password forte!', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_rounded, color: theme.colorScheme.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
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
              const SizedBox(height: 20),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Conferma Password',
                  prefixIcon: Icon(Icons.lock_rounded, color: theme.colorScheme.primary),
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
                      onPressed: _handleSignup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        elevation: 5,
                      ),
                      child: const Text('REGISTRATI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: Text('Hai già un account? Accedi', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

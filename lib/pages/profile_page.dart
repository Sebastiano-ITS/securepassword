import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import 'auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SecureStorageService _storageService = SecureStorageService();
  String _username = 'Caricamento...'; // Stato iniziale
  
  @override
  void initState() {
    super.initState();
    _loadUsername();
  }
  
  // Carica l'username dal Secure Storage
  Future<void> _loadUsername() async {
    final storedUsername = await _storageService.getMasterUsername();
    setState(() {
      // Se l'username è null, usiamo un placeholder
      _username = storedUsername ?? 'Utente Sconosciuto';
    });
  }

  // Funzione per eseguire il logout e tornare alla pagina di autenticazione
  void _logout(BuildContext context) async {
    await _storageService.logout();
    if (context.mounted) {
      // Naviga alla pagina di autenticazione e rimuovi tutte le rotte precedenti
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Qui usiamo l'username caricato in _loadUsername()
    // L'email è ancora un placeholder, ma l'username è dinamico.
    const String email = "master.account@vault.com";

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          Text(
            _username, // Usa l'username dinamico
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            email,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const Divider(height: 40),
          ListTile(
            leading: Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
            title: const Text('Gestisci Master Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implementare la modifica della password master
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funzionalità in costruzione: Modifica Master Password')),
              );
            },
          ),
          const Spacer(),
          // Pulsante Disconnetti (Logout)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('DISCONNETTI'),
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
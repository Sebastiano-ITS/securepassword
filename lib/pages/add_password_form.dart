// lib/pages/add_password_form.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/password_entry.dart';
import '../services/secure_storage_service.dart';

// Funzione per mostrare il dialogo di AGGIUNTA o MODIFICA password
Future<void> showAddPasswordDialog(
    BuildContext context, 
    VoidCallback onPasswordUpdated, 
    {PasswordEntry? existingEntry} // <--- NUOVO PARAMETRO OPZIONALE
) async {
  final SecureStorageService storageService = SecureStorageService();
  
  // Inizializza i controller con i dati esistenti se siamo in modalità modifica
  final TextEditingController titleController = TextEditingController(text: existingEntry?.title);
  final TextEditingController usernameController = TextEditingController(text: existingEntry?.username);
  final TextEditingController emailController = TextEditingController(text: existingEntry?.email);
  final TextEditingController passwordController = TextEditingController(text: existingEntry?.password);

  final isEditing = existingEntry != null;

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(isEditing ? 'Modifica Password' : 'Aggiungi Nuova Password'), // <--- Titolo dinamico
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titolo (es. Google, Banca)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Nome Utente'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Annulla'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          ElevatedButton(
            child: Text(isEditing ? 'AGGIORNA' : 'SALVA'),
            onPressed: () async {
              
              // 1. TRIMMIAMO I TESTI PRIMA DI USARE/VALIDARE
              final title = titleController.text.trim();
              final username = usernameController.text.trim();
              final email = emailController.text.trim();
              final password = passwordController.text; // La password di solito non va trimmata

              // 2. CONDIZIONE DI VALIDAZIONE AGGIORNATA
              // Controlla Titolo e Password E (Username O Email)
              if (title.isNotEmpty &&
                  password.isNotEmpty &&
                  (username.isNotEmpty || email.isNotEmpty)) {
                
                final newEntry = PasswordEntry(
                  id: existingEntry?.id ?? const Uuid().v4(), 
                  title: title, // Usiamo il campo trimmato
                  username: username, // Usiamo il campo trimmato
                  email: email, // Usiamo il campo trimmato
                  password: password,
                );
                
                final storageService = SecureStorageService(); // Assicurati che l'istanza sia disponibile

                if (isEditing) {
                  await storageService.deletePassword(existingEntry.id);
                }
                
                await storageService.addPassword(newEntry); 
                
                onPasswordUpdated(); 
                Navigator.of(dialogContext).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password ${isEditing ? 'aggiornata' : 'salvata'} con successo!')),
                );
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compila Titolo, Password, e almeno Username o Email.')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

// Scheda Placeholder per la Tab "Aggiungi"
class AddPasswordPage extends StatelessWidget {
  const AddPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Quando si seleziona questa tab, il form verrà mostrato in HomePage,
    // quindi questa pagina serve solo come feedback visivo.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle,
            size: 80,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'La scheda "Aggiungi" apre la finestra per creare una nuova password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
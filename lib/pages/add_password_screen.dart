// lib/pages/add_password_form.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/password_entry.dart';
import '../services/secure_storage_service.dart';

// Funzione per mostrare il dialogo di AGGIUNTA o MODIFICA password
Future<void> showAddPasswordDialog(
    BuildContext context, 
    VoidCallback onPasswordUpdated, 
    {PasswordEntry? existingEntry} // <--- PARAMETRO OPZIONALE per la modifica
) async {
  final SecureStorageService storageService = SecureStorageService();
  
  // Inizializza i controller con i dati esistenti se siamo in modalità modifica
  final TextEditingController titleController = TextEditingController(text: existingEntry?.title);
  final TextEditingController usernameController = TextEditingController(text: existingEntry?.username);
  final TextEditingController emailController = TextEditingController(text: existingEntry?.email);
  final TextEditingController passwordController = TextEditingController(text: existingEntry?.password);

  // Inizializza il colore del selettore con quello esistente o con un colore predefinito
  Color selectedColor = existingEntry?.color ?? Colors.grey.shade400;

  final isEditing = existingEntry != null;

  // Stato per la barra di forza all'interno del dialogo
  // Non essendo uno StatefulWidget, usiamo uno StateSetter per aggiornare l'UI locale
  double strengthValue = PasswordEntry.getStrength(passwordController.text);
  
  // Lista di colori suggeriti per la personalizzazione
  final List<Color> suggestedColors = [
    Colors.grey.shade400,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.lightGreen,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
  ];
  
  // Aggiunge un listener per aggiornare la forza in tempo reale
  void updateStrength() {
    strengthValue = PasswordEntry.getStrength(passwordController.text);
  }

  passwordController.addListener(updateStrength);


  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(isEditing ? 'Modifica Password' : 'Aggiungi Nuova Password'),
        content: StatefulBuilder( // StatefulBuilder per aggiornare la UI all'interno del dialogo
          builder: (BuildContext context, StateSetter setState) {
            
            // Per il colore della strength bar
            final strengthColor = PasswordEntry(
              id: '', // Placeholder, non usato per il colore
              title: '', username: '', email: '', password: passwordController.text,
              colorHex: '#CCCCCC',
            ).strengthColor(Theme.of(context));

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Titolo (es. Google, Banca)'),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.vpn_key_rounded),
                        onPressed: () {
                          // TODO: Implementare la generazione di password
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funzione di generazione password in arrivo!')),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // INDICATORE DI FORZA
                  LinearProgressIndicator(
                    value: strengthValue,
                    backgroundColor: Theme.of(context).dividerColor.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                  ),
                  
                  const SizedBox(height: 10),
                  Text(
                    'Forza: ${PasswordEntry.getStrength(passwordController.text).toStringAsFixed(2)}',
                    style: TextStyle(color: strengthColor, fontWeight: FontWeight.bold),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // SELETTORE COLORE
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Colore Card:', style: Theme.of(context).textTheme.titleSmall),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: suggestedColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.only(top: 8.0),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color ? Theme.of(context).colorScheme.primary : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Annulla'),
            onPressed: () {
              passwordController.removeListener(updateStrength);
              Navigator.of(dialogContext).pop();
            },
          ),
          ElevatedButton(
            child: Text(isEditing ? 'SALVA MODIFICHE' : 'SALVA'),
            onPressed: () async {
              passwordController.removeListener(updateStrength);
              
              final title = titleController.text.trim();
              final password = passwordController.text;
              final username = usernameController.text.trim();
              final email = emailController.text.trim();
              
              // Conversione del colore in formato esadecimale per il salvataggio
              final colorHex = '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

              // Validazione minima
              if (title.isNotEmpty && password.isNotEmpty && (username.isNotEmpty || email.isNotEmpty)) {
                
                final newEntry = PasswordEntry(
                  // Manteniamo l'ID esistente se in modalità modifica, altrimenti ne creiamo uno nuovo
                  id: existingEntry?.id ?? const Uuid().v4(), 
                  title: title,
                  username: username,
                  email: email,
                  password: password,
                  colorHex: colorHex,
                );
                
                if (isEditing) {
                  // CHIAMATA CORRETTA PER LA MODIFICA
                  await storageService.updatePassword(newEntry);
                } else {
                  await storageService.addPassword(newEntry);
                }
                
                // Chiama il callback per aggiornare la Dashboard
                onPasswordUpdated(); 
                
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password ${isEditing ? 'aggiornata' : 'salvata'} con successo!') ),
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

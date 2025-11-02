// lib/pages/add_password_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/password_entry.dart';
import '../services/secure_storage_service.dart';

class AddPasswordScreen extends StatefulWidget {
  // Callback da chiamare quando l'operazione è completata (per ricaricare la Dashboard)
  final VoidCallback onPasswordUpdated; 
  // Password esistente per la modalità modifica (opzionale)
  final PasswordEntry? existingEntry; 

  const AddPasswordScreen({
    super.key,
    required this.onPasswordUpdated,
    this.existingEntry,
  });

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  final _formKey = GlobalKey<FormState>();

  // Controller
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isPasswordVisible = false;
  
  // Variabili di stato per il feedback sulla password
  double _strengthValue = 0.0;
  Color _strengthColor = Colors.grey;

  // Inizializzazione dei controller e calcolo iniziale della forza
  @override
  void initState() {
    super.initState();
    final isEditing = widget.existingEntry != null;
    
    _titleController = TextEditingController(text: widget.existingEntry?.title ?? '');
    _usernameController = TextEditingController(text: widget.existingEntry?.username ?? '');
    _emailController = TextEditingController(text: widget.existingEntry?.email ?? '');
    _passwordController = TextEditingController(text: widget.existingEntry?.password ?? '');

    // Calcola la forza iniziale della password (in caso di modifica)
    if (isEditing) {
      _calculatePasswordStrength(widget.existingEntry!.password);
    }
    
    // Ascolta i cambiamenti nel campo password per aggiornare il feedback
    _passwordController.addListener(_onPasswordChanged);
  }

  // Rimuovi l'ascoltatore quando il widget viene eliminato
  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _titleController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // LOGICA: Aggiorna lo stato della forza della password
  void _onPasswordChanged() {
    _calculatePasswordStrength(_passwordController.text);
  }

  // LOGICA: Calcola e imposta i valori di forza e colore
  void _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _strengthValue = 0.0;
        _strengthColor = Theme.of(context).dividerColor;
      });
      return;
    }
    
    final strength = PasswordEntry.getStrength(password);
    final strengthLevel = PasswordEntry(
      id: '', title: '', username: '', email: '', password: password
    ).strengthLevel;
    
    setState(() {
      _strengthValue = strength;
      _strengthColor = PasswordEntry(
        id: '', title: '', username: '', email: '', password: password
      ).strengthColor(Theme.of(context));
    });
  }
  
  // LOGICA: Gestione del salvataggio/aggiornamento
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final title = _titleController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    // Controlli di validazione aggiuntivi (almeno username o email)
    if (title.isEmpty || password.isEmpty || (username.isEmpty && email.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compila Titolo, Password, e almeno Username o Email.')),
      );
      return;
    }

    final isEditing = widget.existingEntry != null;
    final id = isEditing ? widget.existingEntry!.id : const Uuid().v4();

    final newEntry = PasswordEntry(
      id: id,
      title: title,
      username: username,
      email: email,
      password: password,
    );

    if (isEditing) {
      await _storageService.updatePassword(newEntry);
    } else {
      await _storageService.addPassword(newEntry);
    }

    // Successo: Chiama il callback e torna indietro
    widget.onPasswordUpdated();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password ${isEditing ? 'aggiornata' : 'salvata'} con successo!')),
      );
    }
  }

  // Costruisce il campo di input per la password
  Widget _buildPasswordInput(ThemeData theme) {
    final percentage = (_strengthValue * 100).round();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            prefixIcon: const Icon(Icons.lock_rounded),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La password non può essere vuota';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 10),
        
        // Indicatore Forza Password
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '$percentage%',
                style: TextStyle(
                  color: _strengthColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(
                value: _strengthValue,
                backgroundColor: _strengthColor.withOpacity(0.2), 
                valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                minHeight: 8.0,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifica Password' : 'Aggiungi Nuova Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Campo Titolo
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo (es. Google, Banca)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(Icons.label_important_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Il titolo è obbligatorio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 20),

              // Campo Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ),
              
              const SizedBox(height: 30),

              // Campo Password e Feedback Forza
              _buildPasswordInput(theme),
              
              const SizedBox(height: 40),

              // Pulsante Salva
              ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.save_rounded : Icons.add_circle_outline_rounded),
                label: Text(
                  isEditing ? 'Salva Modifiche' : 'Aggiungi Password',
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

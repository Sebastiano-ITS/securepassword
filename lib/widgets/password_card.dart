import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../services/secure_storage_service.dart';
import '../pages/add_password_form.dart';

class PasswordCard extends StatefulWidget {
  final PasswordEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  
  const PasswordCard({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> {
  bool _isPasswordVisible = false;

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copiata negli appunti! 📋'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  void _editPassword() {
    // Chiama la funzione top-level per aprire il dialogo di modifica,
    // pre-compilando con i dati dell'entry.
    showAddPasswordDialog(
      context, 
      widget.onEdit, // Callback per ricaricare la Dashboard dopo la modifica
      existingEntry: widget.entry,
    );
  }

  void _deletePassword() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Sei sicuro di voler eliminare la password per "${widget.entry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = SecureStorageService();
      await storageService.deletePassword(widget.entry.id);
      widget.onDelete();
    }
  }

  // Metodo Helper per mappare la forza a un colore
  Color _getStrengthColor(PasswordStrengthLevel level) {
    switch (level) {
      case PasswordStrengthLevel.blank:
        return Colors.transparent;
      case PasswordStrengthLevel.weak:
        return Colors.red.shade600;
      case PasswordStrengthLevel.medium:
        return Colors.orange.shade600;
      case PasswordStrengthLevel.strong:
        return Colors.blue.shade600;
      case PasswordStrengthLevel.veryStrong:
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  // Metodo Helper per mappare la forza a un valore (per il LinearProgressIndicator)
  double _getStrengthValue(PasswordStrengthLevel level) {
    switch (level) {
      case PasswordStrengthLevel.blank:
        return 0.0;
      case PasswordStrengthLevel.weak:
        return 0.3;
      case PasswordStrengthLevel.medium:
        return 0.5;
      case PasswordStrengthLevel.strong:
        return 0.75;
      case PasswordStrengthLevel.veryStrong:
        return 1.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Testo visualizzato per la password (o i puntini)
    final String passwordText = _isPasswordVisible
        ? widget.entry.password
        : '•' * 15;

    // Gestione della visualizzazione combinata Username/Email
    String userDisplay = widget.entry.username.isNotEmpty 
      ? widget.entry.username 
      : widget.entry.email;
    
    if (widget.entry.username.isNotEmpty && widget.entry.email.isNotEmpty && widget.entry.username != widget.entry.email) {
      userDisplay = "${widget.entry.username} | ${widget.entry.email}";
    }
    
    // Calcolo e visualizzazione della forza
    final strengthLevel = widget.entry.strengthLevel;
    final strengthColor = _getStrengthColor(strengthLevel);
    final strengthValue = _getStrengthValue(strengthLevel);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column( 
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo (Sito/Servizio)
                Text(
                  widget.entry.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 10, color: Colors.transparent),
                
                // Username/Email
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userDisplay,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Password e Pulsanti Azione
                Row(
                  children: [
                    // Icona Chiave
                    Icon(Icons.lock_outline, size: 20, color: theme.colorScheme.secondary),
                    const SizedBox(width: 8),
                    
                    // Password (Oscurata/Visibile)
                    Expanded(
                      child: Text(
                        passwordText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: _isPasswordVisible ? 'monospace' : null, 
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Pulsante Eye (Toggle Visibilità)
                    IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: theme.colorScheme.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      tooltip: 'Mostra/Nascondi Password',
                    ),

                    // Pulsante Copia
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                      onPressed: () => _copyToClipboard(widget.entry.password, context),
                      tooltip: 'Copia Password',
                    ),
                    
                    // Pulsante Modifica
                    IconButton(
                      icon: Icon(Icons.edit_rounded, color: theme.colorScheme.primary),
                      onPressed: _editPassword,
                      tooltip: 'Modifica',
                    ),
                    
                    // Pulsante Elimina
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                      onPressed: _deletePassword,
                      tooltip: 'Elimina',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // INDICATORE FORZA PASSWORD NEL BORDO INFERIORE
          if (strengthLevel != PasswordStrengthLevel.blank)
            Container(
              height: 4.0, 
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)), 
                color: strengthColor.withOpacity(0.3),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                child: LinearProgressIndicator(
                  value: strengthValue,
                  backgroundColor: Colors.transparent, 
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
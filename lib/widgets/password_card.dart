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

  // Funzione per copiare il testo negli appunti
  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copiata negli appunti! 📋'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  // Funzione per aprire il form di modifica
  void _editPassword() {
    // Chiama la funzione top-level per aprire il dialogo di modifica,
    // pre-compilando con i dati dell'entry.
    showAddPasswordDialog(
      context, 
      widget.onEdit, // Callback per ricaricare la Dashboard dopo la modifica
      existingEntry: widget.entry,
    );
  }
  
  // Funzione per eliminare la password
  void _deletePassword() async {
    // Mostra un dialogo di conferma prima dell'eliminazione
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Conferma Eliminazione'),
          content: Text('Sei sicuro di voler eliminare la password per "${widget.entry.title}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Elimina', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final storageService = SecureStorageService();
      await storageService.deletePassword(widget.entry.id);
      widget.onDelete(); // Esegue il callback per aggiornare la Dashboard
     
    }
  }

  // Costruisce la riga con username o email se uno dei due è vuoto
  Widget _buildAccountInfo(ThemeData theme) {
    // Usa un Column per mettere i dati in verticale (come richiesto)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username
        if (widget.entry.username.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              widget.entry.username,
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        
        // Email (solo se non è vuota)
        if (widget.entry.email.isNotEmpty)
          Text(
            widget.entry.email,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Ora accediamo ai getter e ai metodi definiti in PasswordEntry
    final strengthLevel = widget.entry.strengthLevel;
    final strengthColor = widget.entry.strengthColor(theme);
    final strengthValue = widget.entry.strengthValue;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // TITOLO E ICONA
                Row(
                  children: [
                    Icon(Icons.vpn_key_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.entry.title,
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // USERNAME E EMAIL (IN COLONNA)
                _buildAccountInfo(theme), 
                
                const SizedBox(height: 15),
                
                // SEZIONE PASSWORD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () => _copyToClipboard(widget.entry.password, context),
                        child: Text(
                          _isPasswordVisible
                              ? widget.entry.password
                              : '••••••••••••••••',
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'monospace', // Usa un font monospace per le password
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    
                    // Pulsante Visibility
                    IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: theme.colorScheme.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      tooltip: _isPasswordVisible ? 'Nascondi Password' : 'Mostra Password',
                    ),
                    
                    // Pulsante Copia Password
                    IconButton(
                      icon: Icon(Icons.copy, color: theme.colorScheme.secondary.withOpacity(0.7)),
                      onPressed: () => _copyToClipboard(widget.entry.password, context),
                      tooltip: 'Copia Password',
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // SEZIONE AZIONI (MODIFICA / ELIMINA)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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

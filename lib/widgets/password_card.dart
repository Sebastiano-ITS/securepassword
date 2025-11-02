// lib/widgets/password_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../services/secure_storage_service.dart';
// Correzione dell'importazione: ora importiamo la funzione di dialogo dal form
import '../pages/add_password_screen.dart'; 

// Widget riutilizzabile per visualizzare un campo informativo (Username/Email)
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final SecureStorageService storageService = SecureStorageService();
    // Chiedi conferma (usando un dialogo personalizzato, non alert())
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await storageService.deletePassword(widget.entry.id);
      widget.onDelete(); // Esegue il callback per aggiornare la lista nella Dashboard
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password eliminata con successo.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strengthLevel = widget.entry.strengthLevel;
    
    // Calcola il valore di forza (0.0 - 1.0)
    final strengthValue = PasswordEntry.getStrength(widget.entry.password);
    
    // Calcola la percentuale
    final strengthPercentage = (strengthValue * 100).toInt();

    // Determina il colore e il testo della forza
    late Color strengthColor;
    late String strengthText;
    late IconData strengthIcon;

    switch (strengthLevel) {
      case PasswordStrengthLevel.weak:
        strengthColor = Colors.red;
        strengthText = 'Debole';
        strengthIcon = Icons.sentiment_dissatisfied_rounded;
        break;
      case PasswordStrengthLevel.medium:
        strengthColor = Colors.orange;
        strengthText = 'Media';
        strengthIcon = Icons.sentiment_neutral_rounded;
        break;
      case PasswordStrengthLevel.strong:
        strengthColor = Colors.lightGreen;
        strengthText = 'Forte';
        strengthIcon = Icons.sentiment_satisfied_rounded;
        break;
      case PasswordStrengthLevel.veryStrong:
        strengthColor = Colors.green;
        strengthText = 'Molto Forte';
        strengthIcon = Icons.sentiment_very_satisfied_rounded;
        break;
      case PasswordStrengthLevel.blank:
      default:
        // Questo caso non dovrebbe essere raggiunto se strengthLevel != PasswordStrengthLevel.blank
        strengthColor = Colors.grey;
        strengthText = 'N/A';
        strengthIcon = Icons.help_outline_rounded;
        break;
    }


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // Usa il colore della forza come bordo solo se la password non è vuota
        side: strengthLevel != PasswordStrengthLevel.blank 
            ? BorderSide(color: strengthColor.withOpacity(0.5), width: 1.5)
            : BorderSide.none,
      ),
      elevation: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------
                // TITOLO E INDICATORI DI FORZA
                // ------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.entry.title,
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // MOSTRA LA FORZA E LA PERCENTUALE QUI
                    if (strengthLevel != PasswordStrengthLevel.blank)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: strengthColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(strengthIcon, size: 16, color: strengthColor),
                            const SizedBox(width: 6),
                            Text(
                              // AGGIUNTA DELLA PERCENTUALE RICHIESTA
                              '$strengthText ($strengthPercentage%)', 
                              style: theme.textTheme.labelMedium!.copyWith(
                                color: strengthColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const Divider(height: 20),

                // ------------------------------------
                // DETTAGLI (USERNAME / EMAIL)
                // ------------------------------------
                _DetailRow(
                  icon: Icons.person_rounded, 
                  text: widget.entry.username.isNotEmpty ? widget.entry.username : 'Nessun Username',
                ),
                if (widget.entry.email.isNotEmpty)
                  _DetailRow(
                    icon: Icons.email_rounded, 
                    text: widget.entry.email,
                  ),

                const SizedBox(height: 10),
                
                // ------------------------------------
                // PASSWORD NASCOSTA / VISIBILE & AZIONI
                // ------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Testo Password
                      Expanded(
                        child: Text(
                          _isPasswordVisible 
                            ? widget.entry.password 
                            : '•' * widget.entry.password.length, // Caratteri nascosti
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Pulsante Visibility
                      IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
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
                        icon: Icon(Icons.copy_rounded, color: theme.colorScheme.secondary.withOpacity(0.7)),
                        onPressed: () => _copyToClipboard(widget.entry.password, context),
                        tooltip: 'Copia Password',
                      ),
                    ],
                  ),
                ),

                // ------------------------------------
                // AZIONI AGGIUNTIVE (MODIFICA/ELIMINA)
                // ------------------------------------
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
              // Usa la strengthColor
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)), 
                color: strengthColor.withOpacity(0.3),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                child: LinearProgressIndicator(
                  // Usa strengthValue 
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

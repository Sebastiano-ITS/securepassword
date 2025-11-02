import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../services/secure_storage_service.dart';
import '../pages/add_password_screen.dart'; // Correzione dell'importazione

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

  // Funzione per copiare il testo negli appunti
  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    // Mostra una Snackbar più discreta
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiato: $text! 📋'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // NUOVO: Naviga alla pagina di modifica
  void _editPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPasswordScreen(
          existingEntry: widget.entry,
          onPasswordUpdated: widget.onEdit, // Chiama onEdit per ricaricare la Dashboard
        ),
      ),
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
      widget.onDelete(); // Aggiorna la Dashboard
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password per ${widget.entry.title} eliminata.')),
        );
      }
    }
  }

  // Costruisce la sezione informativa (Username/Email) in colonna
  Widget _buildAccountInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.entry.username.isNotEmpty)
          _DetailRow(
            icon: Icons.person_rounded,
            text: widget.entry.username,
          ),
        
        if (widget.entry.email.isNotEmpty)
          _DetailRow(
            icon: Icons.mail_rounded,
            text: widget.entry.email,
          ),
      ],
    );
  }

  // Costruisce l'indicatore di forza con la percentuale
  Widget _buildStrengthIndicator(ThemeData theme, double strengthValue, Color strengthColor, PasswordStrengthLevel strengthLevel) {
    if (strengthLevel == PasswordStrengthLevel.blank) {
      return const SizedBox.shrink(); // Non mostrare nulla se la password è vuota
    }

    // Calcola la percentuale intera
    final percentage = (strengthValue * 100).round();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Row(
        children: [
          // Testo Percentuale
          SizedBox(
            width: 50,
            child: Text(
              '$percentage%',
              style: TextStyle(
                color: strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Indicatore di Progresso
          Expanded(
            child: LinearProgressIndicator(
              value: strengthValue,
              backgroundColor: strengthColor.withOpacity(0.2), 
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
              minHeight: 5.0,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Logica per l'indicatore di forza (definito in PasswordEntry)
    final strengthLevel = widget.entry.strengthLevel;
    final strengthColor = widget.entry.strengthColor(theme);
    final strengthValue = widget.entry.strengthValue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor, // Colore di sfondo della Card
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Ombra per un look più moderno e leggero
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // TITOLO E AZIONI PRINCIPALI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Titolo
                      Expanded(
                        child: Text(
                          widget.entry.title,
                          style: theme.textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Azioni Modifica / Elimina
                      Row(
                        children: [
                          // Pulsante Modifica (ORA USA NAVIGAZIONE)
                          IconButton(
                            icon: Icon(Icons.edit_rounded, color: theme.colorScheme.primary, size: 20),
                            onPressed: _editPassword,
                            tooltip: 'Modifica',
                          ),
                          
                          // Pulsante Elimina
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: _deletePassword,
                            tooltip: 'Elimina',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // USERNAME E EMAIL (IN COLONNA)
                  _buildAccountInfo(theme), 
                  
                  const SizedBox(height: 15),
                ],
              ),
            ),
            
            // INDICATORE FORZA PASSWORD
            _buildStrengthIndicator(theme, strengthValue, strengthColor, strengthLevel),

            // SEZIONE PASSWORD (Sfondo e layout compatto)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              // Sfondo leggermente colorato per la sezione password
              color: theme.colorScheme.surface.withOpacity(0.5), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PASSWORD NASCOSTA O VISIBILE
                  Expanded(
                    child: GestureDetector(
                      onLongPress: () => _copyToClipboard(widget.entry.password, context),
                      child: Text(
                        _isPasswordVisible
                            ? widget.entry.password
                            : '••••••••••••••••',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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
          ],
        ),
      ),
    );
  }
}

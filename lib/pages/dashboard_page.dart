// lib/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../services/secure_storage_service.dart';
import '../widgets/password_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final SecureStorageService _storageService = SecureStorageService();
  late Future<List<PasswordEntry>> _passwordsFuture;

  @override
  void initState() {
    super.initState();
    loadPasswords();
  }

  // Metodo pubblico per ricaricare le password dopo l'aggiunta, eliminazione o modifica
  void loadPasswords() {
    setState(() {
      _passwordsFuture = _storageService.loadPasswords();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⬇️ Il FutureBuilder definisce lo snapshot
    return FutureBuilder<List<PasswordEntry>>(
      future: _passwordsFuture,
      builder: (context, snapshot) { // <--- La variabile 'snapshot' è definita qui!
        
        // ⬇️ Qui puoi usare 'snapshot'
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore nel caricamento: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Nessuna password salvata. Usa la scheda "Aggiungi" (o il pulsante +) per iniziare.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
          );
        }
    
        final passwords = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: passwords.length,
          itemBuilder: (context, index) {
            final entry = passwords[index];
            
            // Usa il nuovo widget PasswordCard per visualizzare i dettagli
            return PasswordCard(
              entry: entry,
              // Passa il callback per ricaricare la lista dopo l'eliminazione
              onDelete: loadPasswords, 
              // Passa il callback per ricaricare la lista dopo la modifica
              onEdit: loadPasswords, 
            );
          },
        );
      },
    );
  }
}
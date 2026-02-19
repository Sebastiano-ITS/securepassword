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

  // Controller e stato per la ricerca
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadPasswords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Metodo pubblico per ricaricare le password dopo l'aggiunta, eliminazione o modifica
  void loadPasswords() {
    setState(() {
      _passwordsFuture = _storageService.loadPasswords();
    });
  }

  // Metodo per filtrare le password in base alla query di ricerca
  List<PasswordEntry> _filterPasswords(List<PasswordEntry> passwords) {
    if (_searchQuery.isEmpty) {
      return passwords; // Mostra tutte le password se non c'è ricerca
    }

    return passwords.where((entry) {
      final titleMatch = entry.title.toLowerCase().contains(_searchQuery);
      final emailMatch = entry.email.toLowerCase().contains(_searchQuery);
      final usernameMatch = entry.username.toLowerCase().contains(_searchQuery);
      return titleMatch || emailMatch || usernameMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<PasswordEntry>>(
      future: _passwordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Errore nel caricamento: ${snapshot.error}'),
          );
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

        final allPasswords = snapshot.data!;
        final filteredPasswords = _filterPasswords(allPasswords);

        return Column(
          children: [
            // Barra di ricerca
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cerca per titolo, email o username...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.secondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: theme.colorScheme.secondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          tooltip: 'Cancella ricerca',
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Lista filtrata
            Expanded(
              child: filteredPasswords.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nessun risultato per "$_searchQuery"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredPasswords.length,
                      itemBuilder: (context, index) {
                        final entry = filteredPasswords[index];

                        return PasswordCard(
                          entry: entry,
                          onDelete: loadPasswords,
                          onEdit: loadPasswords,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

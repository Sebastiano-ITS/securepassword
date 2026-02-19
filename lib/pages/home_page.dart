// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
// CORREZIONE 1: L'importazione corretta della funzione showAddPasswordDialog
// La funzione è definita in 'add_password_form.dart' e non in 'add_password_screen.dart'
import 'add_password_screen.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Key per accedere allo stato della Dashboard (necessario per ricaricare la lista)
  final GlobalKey<DashboardPageState> _dashboardKey = GlobalKey();
  
  // Indice della tab corrente
  int _selectedIndex = 0;

  // Lista di widget per le tab
  late final List<Widget> _pages = [
    DashboardPage(key: _dashboardKey), // 0) Dashboard
    // Non c'è più una pagina dedicata al form qui.
    const ProfilePage(), // 1) Profilo
  ];

  // Modifichiamo l'indice per riflettere solo Dashboard (0) e Profilo (1)
  void _onItemTapped(int index) {
    // Gestisce il caso in cui il FAB (che prima era la tab 1, ora gestita esternamente) venga pressato
    if (index == 2) { 
       setState(() {
        _selectedIndex = 1; // 1 è l'indice di ProfilePage
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Funzione che apre il dialogo per aggiungere la password
  void _showAddForm() {
    // CORREZIONE 2: Chiama la funzione showAddPasswordDialog direttamente.
    // Non è un metodo di _HomePageState, ma una funzione esterna che abbiamo importato.
    // Usiamo il key della Dashboard per chiamare la funzione di ricarica dei dati.
    showAddPasswordDialog(
      context,
      () => _dashboardKey.currentState?.loadPasswords(),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Secure Vault - Dashboard';
      case 1:
        return 'Profilo Master';
      default:
        return 'Secure Vault';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        automaticallyImplyLeading: false, // Disabilita il pulsante back
      ),
      
      // Il corpo cambia a seconda della tab selezionata
      body: _pages[_selectedIndex],
      
      // Floating Action Button al centro (sostituisce la vecchia tab "Aggiungi")
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddForm, // Chiama la funzione corretta
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Implementazione della BottomNavigationBar usando BottomAppBar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: theme.colorScheme.surface, // Assicurati che abbia un colore
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Tab Dashboard
            IconButton(
              icon: Icon(Icons.dashboard_rounded, color: _selectedIndex == 0 ? theme.colorScheme.secondary : Colors.grey),
              onPressed: () => _onItemTapped(0),
              tooltip: 'Dashboard',
            ),
            // Spazio per il FAB
            const SizedBox(width: 48), 
            // Tab Profilo
            IconButton(
              // Corretto: L'indice 1 corrisponde a ProfilePage nella lista _pages
              icon: Icon(Icons.person, color: _selectedIndex == 1 ? theme.colorScheme.secondary : Colors.grey),
              onPressed: () => _onItemTapped(1), 
              tooltip: 'Profilo',
            ),
          ],
        ),
      ),
    );
  }
}

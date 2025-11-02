// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'add_password_screen.dart'; // Importa la nuova pagina
import 'profile_page.dart';
import '../models/password_entry.dart'; // Necessario per il passaggio del tipo

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
  // NB: La tab 1 è un placeholder perché vogliamo un FAB
  late final List<Widget> _pages = [
    DashboardPage(key: _dashboardKey), // 0) Dashboard
    // Non c'è più una pagina dedicata al form qui.
    const ProfilePage(), // 1) Profilo
  ];

  // Modifichiamo l'indice per riflettere solo Dashboard (0) e Profilo (1)
  void _onItemTapped(int index) {
    if (index == 2) { // Se clicca sul terzo elemento (che sarà il profilo)
       setState(() {
        _selectedIndex = 1; // 1 è l'indice di ProfilePage nella lista _pages
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Funzione che naviga alla nuova schermata per l'aggiunta
  void _navigateToAddForm({PasswordEntry? entry}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPasswordScreen(
          existingEntry: entry,
          // Quando il form salva, ricarica le password sulla Dashboard
          onPasswordUpdated: () {
            _dashboardKey.currentState?.loadPasswords();
            // Torna alla Dashboard dopo il salvataggio
            setState(() { _selectedIndex = 0; }); 
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        automaticallyImplyLeading: false, // Disabilita il pulsante back
      ),
      
      // Il corpo cambia a seconda della tab selezionata
      body: _pages[_selectedIndex],
      
      // Pulsante Floating Action Button per Aggiungi
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddForm(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Implementazione della BottomNavigationBar per la TabBar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Tab Dashboard
            IconButton(
              icon: Icon(Icons.dashboard_rounded, color: _selectedIndex == 0 ? Theme.of(context).colorScheme.secondary : Colors.grey),
              onPressed: () => _onItemTapped(0),
              tooltip: 'Dashboard',
            ),
            // Spazio per il FAB
            const SizedBox(width: 48), 
            // Tab Profilo
            IconButton(
              icon: Icon(Icons.person, color: _selectedIndex == 1 ? Theme.of(context).colorScheme.secondary : Colors.grey),
              onPressed: () => _onItemTapped(1), // L'indice 1 corrisponde a ProfilePage nella lista _pages
              tooltip: 'Profilo',
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Secure Vault - Dashboard';
      case 1:
        return 'Profilo Utente';
      default:
        return 'Secure Vault';
    }
  }
}

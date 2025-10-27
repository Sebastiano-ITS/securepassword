// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'add_password_form.dart';
import 'profile_page.dart';

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
    DashboardPage(key: _dashboardKey), // 1) Dashboard
    const AddPasswordPage(), // 2) Pulsante + (Placeholder)
    const ProfilePage(), // 3) Profilo
  ];

  void _onItemTapped(int index) {
    // Se l'utente clicca sulla tab 'Aggiungi', apriamo il form
    if (index == 1) {
      _showAddForm();
    } else {
      // Altrimenti, cambiamo semplicemente la schermata
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Funzione che apre il dialogo per aggiungere la password
  void _showAddForm() {
    showAddPasswordDialog(context, () {
      // Dopo l'aggiunta, ricarica la lista nella Dashboard chiamando il metodo pubblico
      _dashboardKey.currentState?.loadPasswords();
    });
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
      
      // Implementazione della BottomNavigationBar per la TabBar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Aggiungi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
        currentIndex: _selectedIndex,
        // Usiamo un colore neutro per la background, e i colori del tema per selezione
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
  
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Secure Vault - Dashboard';
      case 1:
        return 'Aggiungi Password';
      case 2:
        return 'Profilo Utente';
      default:
        return 'Secure Vault';
    }
  }
}
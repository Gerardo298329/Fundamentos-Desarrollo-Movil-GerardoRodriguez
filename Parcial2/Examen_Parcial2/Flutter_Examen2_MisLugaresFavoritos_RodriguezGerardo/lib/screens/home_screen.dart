import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/map_screen.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/place_form_screen.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/places_list_screen.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/profile_screen.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/places_controller.dart';

/// Contenedor principal con navegación inferior: Lista, Mapa y Perfil.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    PlacesController.instance.load();
  }

  void _openForm() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlaceFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack conserva el estado de cada pestaña (posición del mapa, scroll, etc.).
      body: IndexedStack(
        index: _index,
        children: const [
          PlacesListScreen(),
          MapScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: _index == 2
          ? null
          : FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Nuevo lugar'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Lugares'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
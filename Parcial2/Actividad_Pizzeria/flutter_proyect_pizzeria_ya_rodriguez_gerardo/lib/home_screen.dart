import 'package:flutter/material.dart';
import 'mapa_screen.dart';
import 'armar_pizza_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: indice,
        children: const [MapaScreen(), ArmarPizzaScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indice,
        onTap: (i) => setState(() => indice = i),
        selectedItemColor: const Color(0xFFE64040),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_pizza), label: 'Arma tu pizza'),
        ],
      ),
    );
  }
}
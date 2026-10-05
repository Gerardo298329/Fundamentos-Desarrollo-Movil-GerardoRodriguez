import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'carrito_model.dart';
import 'login_screen.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => CarritoModel(),
    child: const PizzeriaYa(),
  ),
);

class PizzeriaYa extends StatelessWidget {
  const PizzeriaYa({super.key});

  @override
  Widget build(BuildContext context) {
    const rojo = Color(0xFFE64040);
    return MaterialApp(
      title: 'Pizzería Ya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: rojo, primary: rojo),
        scaffoldBackgroundColor: const Color(0xFFF7F2EA),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F2EA),
            elevation: 0,
            foregroundColor: Colors.black87),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: rojo,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder()),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
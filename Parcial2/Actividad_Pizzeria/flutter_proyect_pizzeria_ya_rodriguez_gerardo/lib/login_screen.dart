import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const rojo = Color(0xFFE64040);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Text('Pizzería Ya',
                  style: TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold, color: rojo)),
              const SizedBox(height: 24),
              Container(
                width: 140,
                height: 140,
                decoration:
                const BoxDecoration(shape: BoxShape.circle, color: rojo),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFFF0C94D)),
                    child: const Center(
                      child: Text('PIZZA',
                          style: TextStyle(
                              color: rojo, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Las mejores pizzas',
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ),
                  child: const Text('Iniciar Sesión',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
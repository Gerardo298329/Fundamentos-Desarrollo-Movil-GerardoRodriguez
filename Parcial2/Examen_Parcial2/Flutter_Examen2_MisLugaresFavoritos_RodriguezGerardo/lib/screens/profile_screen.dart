import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/categories.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/utils.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/places_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      PlacesController.instance.clear();
      await Supabase.instance.client.auth.signOut();
      // AuthGate detecta el cambio de sesión y muestra la pantalla de acceso.
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Usuario';
    final controller = PlacesController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final places = controller.all;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    email.substring(0, 1).toUpperCase(),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(email, style: theme.textTheme.titleMedium)),
              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: places.length),
                        duration: const Duration(milliseconds: 600),
                        builder: (_, value, __) => Text(
                          '$value',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text('lugares guardados'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Desglose por categoría (solo las que tienen al menos un lugar).
              for (final c in kCategories)
                if (places.any((p) => p.category == c.name))
                  ListTile(
                    leading: Icon(c.icon, color: c.color),
                    title: Text(c.name),
                    trailing: Text(
                      '${places.where((p) => p.category == c.name).length}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),

              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                onPressed: () => _logout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
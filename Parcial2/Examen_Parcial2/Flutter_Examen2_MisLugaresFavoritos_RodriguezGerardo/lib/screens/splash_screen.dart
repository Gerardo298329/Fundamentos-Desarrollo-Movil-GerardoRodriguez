import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/auth_screen.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pantalla de bienvenida con animación; después delega en [AuthGate].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  late final Animation<double> _fade =
  CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  late final Animation<double> _scale = Tween<double>(begin: 0.6, end: 1)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, size: 96, color: scheme.onPrimary),
                const SizedBox(height: 16),
                Text(
                  'Mis Lugares Favoritos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Decide qué pantalla mostrar según el estado de la sesión de Supabase.
/// Reacciona a login, registro y logout sin navegación manual.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        return session != null ? const HomeScreen() : const AuthScreen();
      },
    );
  }
}
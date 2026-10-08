import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/app_theme.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/supabase_config.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // La sesión se persiste automáticamente en el almacenamiento local del dispositivo.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MisLugaresApp());
}

class MisLugaresApp extends StatelessWidget {
  const MisLugaresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Lugares Favoritos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
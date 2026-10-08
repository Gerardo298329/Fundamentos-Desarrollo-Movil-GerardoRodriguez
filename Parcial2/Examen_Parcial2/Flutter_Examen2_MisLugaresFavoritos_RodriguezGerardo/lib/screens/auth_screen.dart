import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pantalla única para iniciar sesión o registrarse.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = Supabase.instance.client.auth;
    try {
      if (_isLogin) {
        await auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      } else {
        final response = await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        // Sin sesión: el proyecto exige confirmar el correo antes de ingresar.
        if (response.session == null && mounted) {
          showSnack(context, 'Revisa tu correo para confirmar la cuenta.');
        }
      }
      // La navegación la resuelve AuthGate al detectar la nueva sesión.
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.favorite, size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Mis Lugares Favoritos',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isLogin ? 'Inicia sesión para continuar' : 'Crea tu cuenta',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Ingresa tu correo';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Mínimo 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                        : Text(_isLogin ? 'Iniciar sesión' : 'Registrarme'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? '¿No tienes cuenta? Regístrate'
                          : '¿Ya tienes cuenta? Inicia sesión',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
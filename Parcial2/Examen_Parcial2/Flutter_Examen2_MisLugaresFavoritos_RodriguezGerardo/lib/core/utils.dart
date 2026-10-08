import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Convierte una excepción en un mensaje legible para el usuario.
String friendlyError(Object error) {
  final raw = error.toString();

  // Fallas de red: se evalúan primero porque pueden venir envueltas en otras excepciones.
  if (raw.contains('SocketException') ||
      raw.contains('ClientException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('Connection refused')) {
    return 'Sin conexión a internet. Verifica tu red e inténtalo de nuevo.';
  }
  if (error is LocationException) return error.message;
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (msg.contains('already registered')) {
      return 'Este correo ya está registrado.';
    }
    if (msg.contains('password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return error.message;
  }
  if (error is PostgrestException) {
    return 'Error del servidor: ${error.message}';
  }
  if (error is StorageException) {
    return 'Error al manejar la imagen: ${error.message}';
  }
  return 'Ocurrió un error inesperado. Inténtalo nuevamente.';
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
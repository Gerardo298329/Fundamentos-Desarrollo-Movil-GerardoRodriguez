import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/utils.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/models/place.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/places_controller.dart';

/// Solicita confirmación y, si se acepta, elimina el lugar.
Future<void> confirmDelete(BuildContext context, Place place) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar lugar'),
      content: Text('¿Seguro que deseas eliminar "${place.name}"? '
          'Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
            minimumSize: const Size(100, 44),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    await PlacesController.instance.remove(place);
    if (context.mounted) showSnack(context, 'Lugar eliminado');
  } catch (e) {
    if (context.mounted) showSnack(context, friendlyError(e));
  }
}
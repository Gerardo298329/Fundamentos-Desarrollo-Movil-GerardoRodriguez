import 'package:flutter/material.dart';
import 'models.dart';

class SelectorNivel extends StatelessWidget {
  const SelectorNivel({super.key, required this.nivel, required this.onChanged});
  final Nivel nivel;
  final ValueChanged<Nivel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed:
        nivel.index > 0 ? () => onChanged(Nivel.values[nivel.index - 1]) : null,
      ),
      SizedBox(
        width: 64,
        child: Text(nivel.texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: nivel.index < Nivel.values.length - 1
            ? () => onChanged(Nivel.values[nivel.index + 1])
            : null,
      ),
    ]);
  }
}
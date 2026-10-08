import 'package:flutter/material.dart';

/// Categoría de lugar con su icono y color asociados.
class PlaceCategory {
  const PlaceCategory(this.name, this.icon, this.color);

  final String name;
  final IconData icon;
  final Color color;
}

const List<PlaceCategory> kCategories = [
  PlaceCategory('Comida', Icons.restaurant, Color(0xFFE65100)),
  PlaceCategory('Estudio', Icons.school, Color(0xFF1565C0)),
  PlaceCategory('Diversión', Icons.celebration, Color(0xFF8E24AA)),
  PlaceCategory('Deporte', Icons.fitness_center, Color(0xFF2E7D32)),
  PlaceCategory('Hogar', Icons.home, Color(0xFF6D4C41)),
  PlaceCategory('Trabajo', Icons.work, Color(0xFF455A64)),
  PlaceCategory('Naturaleza', Icons.park, Color(0xFF00897B)),
  PlaceCategory('Otro', Icons.place, Color(0xFFC62828)),
];

/// Devuelve la categoría por nombre; usa "Otro" si no existe.
PlaceCategory categoryOf(String name) => kCategories.firstWhere(
      (c) => c.name == name,
  orElse: () => kCategories.last,
);
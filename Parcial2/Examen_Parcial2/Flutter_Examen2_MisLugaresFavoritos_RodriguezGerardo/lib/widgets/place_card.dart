import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/categories.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/models/place.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/place_form_screen.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/widgets/confirm_delete.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final category = categoryOf(place.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 64,
            height: 64,
            child: place.photoUrl != null
                ? Image.network(
              place.photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _iconBox(category),
            )
                : _iconBox(category),
          ),
        ),
        title: Text(
          place.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.icon, size: 14, color: category.color),
                const SizedBox(width: 4),
                Text(category.name),
              ],
            ),
            if (place.description != null && place.description!.isNotEmpty)
              Text(
                place.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _edit(context);
            } else {
              confirmDelete(context, place);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
        onTap: () => _edit(context),
      ),
    );
  }

  Widget _iconBox(PlaceCategory category) => Container(
    color: category.color.withValues(alpha: 0.15),
    child: Icon(category.icon, color: category.color, size: 30),
  );

  void _edit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceFormScreen(place: place)),
    );
  }
}
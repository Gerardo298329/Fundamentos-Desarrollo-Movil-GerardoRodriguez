import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/models/picked_photo.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/categories.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/utils.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/models/place.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/location_picker_screen.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/places_controller.dart';

/// Formulario para crear un lugar o editar uno existente (si se recibe [place]).
class PlaceFormScreen extends StatefulWidget {
  const PlaceFormScreen({super.key, this.place});

  final Place? place;

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
  TextEditingController(text: widget.place?.name);
  late final TextEditingController _description =
  TextEditingController(text: widget.place?.description);

  late String _category = widget.place?.category ?? kCategories.first.name;
  late LatLng? _position = widget.place?.position;

  PickedPhoto? _newPhoto;
  bool _removePhoto = false;
  bool _saving = false;

  bool get _isEditing => widget.place != null;

  bool get _hasPhoto =>
      _newPhoto != null || (widget.place?.photoUrl != null && !_removePhoto);

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      // Se reduce el tamaño para optimizar la subida y el almacenamiento.
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _newPhoto = PickedPhoto(
          bytes: bytes,
          extension: _extensionOf(picked.name),
        );
        _removePhoto = false;
      });
    } catch (_) {
      if (mounted) showSnack(context, 'No se pudo acceder a la imagen.');
    }
  }

  /// Obtiene una extensión válida a partir del nombre del archivo.
  String _extensionOf(String fileName) {
    final ext =
    fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    const allowed = {'png', 'jpg', 'jpeg', 'webp'};
    return allowed.contains(ext) ? ext : 'jpg';
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initial: _position),
      ),
    );
    if (result != null) setState(() => _position = result);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_position == null) {
      showSnack(context, 'Selecciona la ubicación del lugar en el mapa.');
      return;
    }

    setState(() => _saving = true);

    final description = _description.text.trim().isEmpty
        ? null
        : _description.text.trim();

    try {
      final controller = PlacesController.instance;
      if (_isEditing) {
        await controller.edit(
          widget.place!,
          name: _name.text.trim(),
          description: description,
          category: _category,
          position: _position!,
          newPhoto: _newPhoto,
          removePhoto: _removePhoto,
        );
      } else {
        await controller.add(
          name: _name.text.trim(),
          description: description,
          category: _category,
          position: _position!,
          photo: _newPhoto,
        );
      }
      if (!mounted) return;
      showSnack(context, _isEditing ? 'Lugar actualizado' : 'Lugar guardado');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _photoPreview() {
    if (_newPhoto != null) {
      return Image.memory(_newPhoto!.bytes, fit: BoxFit.cover);
    }
    final url = widget.place?.photoUrl;
    if (url != null && !_removePhoto) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image_outlined, size: 40),
        ),
      );
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 40),
          SizedBox(height: 8),
          Text('Agregar foto'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar lugar' : 'Nuevo lugar'),
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Foto
              GestureDetector(
                onTap: _choosePhoto,
                child: Container(
                  height: 180,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _photoPreview(),
                ),
              ),
              if (_hasPhoto)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Quitar foto'),
                    onPressed: () => setState(() {
                      _newPhoto = null;
                      _removePhoto = true;
                    }),
                  ),
                ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del lugar',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _description,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 20),

              Text('Categoría', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in kCategories)
                    ChoiceChip(
                      avatar: Icon(c.icon, size: 18, color: c.color),
                      label: Text(c.name),
                      selected: _category == c.name,
                      onSelected: (_) => setState(() => _category = c.name),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: _position == null
                        ? theme.colorScheme.outline
                        : theme.colorScheme.primary,
                  ),
                  title: const Text('Ubicación'),
                  subtitle: Text(
                    _position == null
                        ? 'Sin seleccionar'
                        : '${_position!.latitude.toStringAsFixed(5)}, '
                        '${_position!.longitude.toStringAsFixed(5)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickLocation,
                ),
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
                    : Text(_isEditing ? 'Guardar cambios' : 'Guardar lugar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/categories.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/utils.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/models/place.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/screens/place_form_screen.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/location_service.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/places_controller.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/widgets/confirm_delete.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/widgets/filter_widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Centro inicial genérico (México) mientras se obtiene la ubicación real.
  static const LatLng _fallbackCenter = LatLng(23.6345, -102.5528);

  final MapController _mapController = MapController();
  final PlacesController _places = PlacesController.instance;
  LatLng? _myPosition;

  Future<void> _locate({bool silent = false}) async {
    try {
      final position = await LocationService.current();
      if (!mounted) return;
      setState(() => _myPosition = position);
      _mapController.move(position, 15);
    } catch (e) {
      if (mounted && !silent) showSnack(context, friendlyError(e));
    }
  }

  void _fitAll() {
    final points = _places.filtered.map((p) => p.position).toList();
    if (points.isEmpty) {
      showSnack(context, 'No hay lugares para mostrar.');
      return;
    }
    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.all(72),
      ),
    );
  }

  void _showDetails(Place place) {
    final category = categoryOf(place.category);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      // Permite que la hoja use todo el alto disponible.
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        // Desplazamiento como respaldo si el contenido no cabe en pantallas bajas.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (place.photoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    place.photoUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(category.icon, color: category.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              Text(category.name),
              if (place.description != null && place.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(place.description!),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PlaceFormScreen(place: place),
                        ));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        confirmDelete(context, place);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListenableBuilder(
          listenable: _places,
          builder: (context, _) {
            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _fallbackCenter,
                initialZoom: 5,
                // Al estar listo el mapa se centra en la ubicación del dispositivo.
                onMapReady: () => _locate(silent: true),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // Debe coincidir con el applicationId del proyecto.
                  userAgentPackageName: 'com.example.mis_lugares',
                ),
                MarkerLayer(
                  markers: [
                    for (final place in _places.filtered)
                      Marker(
                        point: place.position,
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _showDetails(place),
                          child: Icon(
                            Icons.location_on,
                            size: 44,
                            color: categoryOf(place.category).color,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_myPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _myPosition!,
                        width: 28,
                        height: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(blurRadius: 6, color: Colors.black38),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                // Atribución obligatoria según la política de uso de OpenStreetMap.
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            );
          },
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: PlaceSearchField(),
                    ),
                    SizedBox(height: 4),
                    CategoryFilterBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 88,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'fit_all',
                tooltip: 'Ver todos mis lugares',
                onPressed: _fitAll,
                child: const Icon(Icons.zoom_out_map),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'my_location',
                tooltip: 'Mi ubicación',
                onPressed: _locate,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
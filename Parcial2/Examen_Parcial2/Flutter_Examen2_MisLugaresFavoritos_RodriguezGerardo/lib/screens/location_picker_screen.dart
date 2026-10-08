import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/utils.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/location_service.dart';

/// Permite elegir un punto tocando el mapa. Devuelve un [LatLng] al confirmar.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initial});

  final LatLng? initial;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const LatLng _fallbackCenter = LatLng(23.6345, -102.5528);

  final MapController _mapController = MapController();
  LatLng? _selected;
  LatLng? _myPosition;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  Future<void> _locate({bool silent = false}) async {
    try {
      final position = await LocationService.current();
      if (!mounted) return;
      setState(() => _myPosition = position);
      _mapController.move(position, 16);
    } catch (e) {
      if (mounted && !silent) showSnack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elegir ubicación')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initial ?? _fallbackCenter,
              initialZoom: widget.initial != null ? 16 : 5,
              onMapReady: () {
                // Sin punto previo, se centra el mapa en la posición actual.
                if (widget.initial == null) _locate(silent: true);
              },
              onTap: (_, point) => setState(() => _selected = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mis_lugares',
              ),
              if (_myPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _myPosition!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 96,
            child: FloatingActionButton.small(
              heroTag: 'picker_location',
              tooltip: 'Mi ubicación',
              onPressed: _locate,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: const Icon(Icons.check),
            label: Text(
              _selected == null
                  ? 'Toca el mapa para marcar el lugar'
                  : 'Confirmar ubicación',
            ),
            onPressed: _selected == null
                ? null
                : () => Navigator.of(context).pop(_selected),
          ),
        ),
      ),
    );
  }
}
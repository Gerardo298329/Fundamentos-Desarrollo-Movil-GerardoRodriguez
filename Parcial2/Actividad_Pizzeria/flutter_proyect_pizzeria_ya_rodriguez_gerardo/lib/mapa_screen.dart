import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Sucursal {
  final String nombre;
  final String direccion;
  final LatLng ubicacion;
  Sucursal(this.nombre, this.direccion, this.ubicacion);
}

// Datos de ejemplo (coordenadas aproximadas).
final sucursales = [
  Sucursal('Pizzería Ya Plaza del Carmen', 'Centro Histórico, San Luis Potosí',
      LatLng(22.1508, -100.9785)),
  Sucursal('Pizzería Ya Plaza de Armas', 'Centro Histórico, San Luis Potosí',
      LatLng(22.1512, -100.9763)),
  Sucursal('Pizzería Ya Alameda', 'Zona Centro, San Luis Potosí',
      LatLng(22.1467, -100.9722)),
];

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  void _detalle(BuildContext context, Sucursal s) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.nombre,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(s.direccion),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuestras sucursales')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(22.1508, -100.9775),
          initialZoom: 15.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.pizzeria_ya',
          ),
          MarkerLayer(
            markers: [
              for (final s in sucursales)
                Marker(
                  point: s.ubicacion,
                  width: 48,
                  height: 48,
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () => _detalle(context, s),
                    child: const Icon(Icons.location_on,
                        color: Color(0xFFE64040), size: 44),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Encapsula la obtención de la ubicación actual del dispositivo.
class LocationService {
  static Future<LatLng> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'El GPS está desactivado. Actívalo para ver tu ubicación.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Permiso de ubicación denegado.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Permiso de ubicación bloqueado. Habilítalo desde los ajustes del sistema.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }
}
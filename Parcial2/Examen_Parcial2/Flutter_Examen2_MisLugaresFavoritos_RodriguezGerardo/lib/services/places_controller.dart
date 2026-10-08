import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/models/picked_photo.dart';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/utils.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/models/place.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/places_service.dart';

/// Estado compartido de los lugares del usuario (lista, mapa y perfil).
/// Mantiene también el texto de búsqueda y la categoría seleccionada,
/// de modo que el filtro se aplique de forma consistente en toda la app.
class PlacesController extends ChangeNotifier {
  PlacesController._();
  static final PlacesController instance = PlacesController._();

  final PlacesService _service = PlacesService();

  List<Place> _all = [];
  String _query = '';
  String? _category;
  bool _loading = false;
  String? _error;

  List<Place> get all => _all;
  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  String? get category => _category;

  bool _filtersExpanded = true;
  bool get filtersExpanded => _filtersExpanded;

  List<Place> get filtered {
    final q = _query.trim().toLowerCase();
    return _all.where((p) {
      final matchesName = q.isEmpty || p.name.toLowerCase().contains(q);
      final matchesCategory = _category == null || p.category == _category;
      return matchesName && matchesCategory;
    }).toList();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _category = value;
    notifyListeners();
  }

  void toggleFilters() {
    _filtersExpanded = !_filtersExpanded;
    notifyListeners();
  }

  /// Limpia el estado local (se invoca al cerrar sesión).
  void clear() {
    _all = [];
    _query = '';
    _category = null;
    _error = null;
    _filtersExpanded = true;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await _service.fetchAll();
    } catch (e) {
      _error = friendlyError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add({
    required String name,
    required String category,
    required LatLng position,
    String? description,
    PickedPhoto? photo,
  }) async {
    String? photoUrl;
    if (photo != null) photoUrl = await _service.uploadPhoto(photo);

    try {
      final created = await _service.create({
        'name': name,
        'description': description,
        'category': category,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'photo_url': photoUrl,
      });
      _all = [created, ..._all];
      notifyListeners();
    } catch (_) {
      // Evita dejar archivos huérfanos si falló el registro en la base de datos.
      if (photoUrl != null) await _safeDeletePhoto(photoUrl);
      rethrow;
    }
  }

  Future<void> edit(
      Place original, {
        required String name,
        required String category,
        required LatLng position,
        String? description,
        PickedPhoto? newPhoto,
        bool removePhoto = false,
      }) async {
    String? photoUrl = original.photoUrl;
    String? uploaded;

    if (newPhoto != null) {
      uploaded = await _service.uploadPhoto(newPhoto);
      photoUrl = uploaded;
    } else if (removePhoto) {
      photoUrl = null;
    }

    try {
      final updated = await _service.update(original.id, {
        'name': name,
        'description': description,
        'category': category,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'photo_url': photoUrl,
      });
      _all = _all.map((p) => p.id == updated.id ? updated : p).toList();
      notifyListeners();
    } catch (_) {
      if (uploaded != null) await _safeDeletePhoto(uploaded);
      rethrow;
    }

    // Se elimina la imagen anterior solo si fue reemplazada o retirada.
    final previous = original.photoUrl;
    if (previous != null && previous != photoUrl) {
      await _safeDeletePhoto(previous);
    }
  }

  Future<void> remove(Place place) async {
    await _service.delete(place.id);
    _all = _all.where((p) => p.id != place.id).toList();
    notifyListeners();
    if (place.photoUrl != null) await _safeDeletePhoto(place.photoUrl!);
  }

  Future<void> _safeDeletePhoto(String url) async {
    try {
      await _service.deletePhoto(url);
    } catch (_) {
      // La limpieza de archivos es secundaria; no debe interrumpir la operación principal.
    }
  }
}
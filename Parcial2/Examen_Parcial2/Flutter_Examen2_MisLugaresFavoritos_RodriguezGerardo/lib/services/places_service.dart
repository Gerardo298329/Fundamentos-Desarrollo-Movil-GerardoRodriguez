import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/models/picked_photo.dart';

import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/models/place.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Acceso directo a Supabase: tabla `places` y bucket `place-photos`.
class PlacesService {
  static const String _table = 'places';
  static const String _bucket = 'place-photos';

  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Place>> fetchAll() async {
    final rows =
    await _db.from(_table).select().order('created_at', ascending: false);
    return rows.map<Place>(Place.fromMap).toList();
  }

  Future<Place> create(Map<String, dynamic> data) async {
    final row = await _db.from(_table).insert(data).select().single();
    return Place.fromMap(row);
  }

  Future<Place> update(String id, Map<String, dynamic> data) async {
    final row =
    await _db.from(_table).update(data).eq('id', id).select().single();
    return Place.fromMap(row);
  }

  Future<void> delete(String id) async {
    await _db.from(_table).delete().eq('id', id);
  }

  /// Sube la imagen a `<user_id>/<timestamp>.<ext>` y devuelve su URL pública.
  Future<String> uploadPhoto(PickedPhoto photo) async {
    final uid = _db.auth.currentUser!.id;
    final path =
        '$uid/${DateTime.now().millisecondsSinceEpoch}.${photo.extension}';

    await _db.storage.from(_bucket).uploadBinary(
      path,
      photo.bytes,
      fileOptions: FileOptions(contentType: photo.contentType),
    );
    return _db.storage.from(_bucket).getPublicUrl(path);
  }

  /// Elimina una imagen a partir de su URL pública.
  Future<void> deletePhoto(String url) async {
    final marker = '/$_bucket/';
    final index = url.indexOf(marker);
    if (index == -1) return;
    final path = url.substring(index + marker.length);
    await _db.storage.from(_bucket).remove([path]);
  }
}
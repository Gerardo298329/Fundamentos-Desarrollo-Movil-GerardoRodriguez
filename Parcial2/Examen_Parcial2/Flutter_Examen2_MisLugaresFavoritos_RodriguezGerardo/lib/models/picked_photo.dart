import 'dart:typed_data';

/// Imagen seleccionada por el usuario, almacenada en memoria.
/// Se usan bytes en lugar de `File` para ser compatible con Flutter Web.
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.extension});

  final Uint8List bytes;
  final String extension;

  String get contentType {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
import 'package:latlong2/latlong.dart';

class Place {
  const Place({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.description,
    this.photoUrl,
  });

  final String id;
  final String userId;
  final String name;
  final String? description;
  final String category;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final DateTime createdAt;

  LatLng get position => LatLng(latitude, longitude);

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
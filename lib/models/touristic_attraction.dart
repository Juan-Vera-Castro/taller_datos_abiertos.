import 'city.dart';

/// Atractivo turístico (endpoint `/TouristicAttraction`).
class TouristicAttraction {
  final int id;
  final String name;
  final String description;
  final List<String> images;

  /// La API entrega las coordenadas como texto.
  final String latitude;
  final String longitude;
  final int? cityId;
  final City? city;

  const TouristicAttraction({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.latitude,
    required this.longitude,
    this.cityId,
    this.city,
  });

  factory TouristicAttraction.fromJson(Map<String, dynamic> json) {
    final city = json['city'];
    return TouristicAttraction(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      cityId: (json['cityId'] as num?)?.toInt(),
      city: city is Map<String, dynamic> ? City.fromJson(city) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'images': images,
        'latitude': latitude,
        'longitude': longitude,
        'cityId': cityId,
        'city': city?.toJson(),
      };
}

import 'city.dart';

/// Departamento de Colombia (endpoint `/Department`).
class Department {
  final int id;
  final String name;
  final String description;
  final int? cityCapitalId;
  final int? municipalities;
  final int? surface;
  final int? population;
  final String? phonePrefix;
  final int? regionId;
  final City? cityCapital;

  const Department({
    required this.id,
    required this.name,
    required this.description,
    this.cityCapitalId,
    this.municipalities,
    this.surface,
    this.population,
    this.phonePrefix,
    this.regionId,
    this.cityCapital,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    final cityCapital = json['cityCapital'];
    return Department(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cityCapitalId: (json['cityCapitalId'] as num?)?.toInt(),
      municipalities: (json['municipalities'] as num?)?.toInt(),
      surface: (json['surface'] as num?)?.toInt(),
      population: (json['population'] as num?)?.toInt(),
      phonePrefix: json['phonePrefix'] as String?,
      regionId: (json['regionId'] as num?)?.toInt(),
      cityCapital: cityCapital is Map<String, dynamic>
          ? City.fromJson(cityCapital)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cityCapitalId': cityCapitalId,
        'municipalities': municipalities,
        'surface': surface,
        'population': population,
        'phonePrefix': phonePrefix,
        'regionId': regionId,
        'cityCapital': cityCapital?.toJson(),
      };
}

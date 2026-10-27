/// Ciudad de Colombia. Aparece anidada en `Department.cityCapital`
/// y en `TouristicAttraction.city`.
class City {
  final int id;
  final String name;
  final String description;
  final int? surface;
  final int? population;
  final String? postalCode;
  final int? departmentId;

  const City({
    required this.id,
    required this.name,
    required this.description,
    this.surface,
    this.population,
    this.postalCode,
    this.departmentId,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      surface: (json['surface'] as num?)?.toInt(),
      population: (json['population'] as num?)?.toInt(),
      postalCode: json['postalCode'] as String?,
      departmentId: (json['departmentId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'surface': surface,
        'population': population,
        'postalCode': postalCode,
        'departmentId': departmentId,
      };
}

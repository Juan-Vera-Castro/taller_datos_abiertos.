import 'department.dart';

/// Plato típico (endpoint `/TypicalDish`).
class TypicalDish {
  final int id;
  final String name;
  final String description;
  final String ingredients;
  final String imageUrl;
  final int? departmentId;
  final Department? department;

  const TypicalDish({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.imageUrl,
    this.departmentId,
    this.department,
  });

  /// Los ingredientes llegan como un texto separado por comas.
  List<String> get ingredientList => ingredients
      .replaceAll(RegExp(r'\.$'), '')
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  factory TypicalDish.fromJson(Map<String, dynamic> json) {
    final department = json['department'];
    return TypicalDish(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ingredients: json['ingredients'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      departmentId: (json['departmentId'] as num?)?.toInt(),
      department: department is Map<String, dynamic>
          ? Department.fromJson(department)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'ingredients': ingredients,
        'imageUrl': imageUrl,
        'departmentId': departmentId,
        'department': department?.toJson(),
      };
}

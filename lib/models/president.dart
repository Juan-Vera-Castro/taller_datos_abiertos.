/// Presidente de Colombia (endpoint `/President`).
class President {
  final int id;
  final String image;
  final String name;
  final String lastName;
  final String startPeriodDate;

  /// `null` cuando el periodo sigue vigente.
  final String? endPeriodDate;
  final String politicalParty;
  final String description;
  final int? cityId;

  const President({
    required this.id,
    required this.image,
    required this.name,
    required this.lastName,
    required this.startPeriodDate,
    this.endPeriodDate,
    required this.politicalParty,
    required this.description,
    this.cityId,
  });

  String get fullName => '$name $lastName'.trim();

  String get period => '$startPeriodDate — ${endPeriodDate ?? 'Actualidad'}';

  factory President.fromJson(Map<String, dynamic> json) {
    return President(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      startPeriodDate: json['startPeriodDate'] as String? ?? '',
      endPeriodDate: json['endPeriodDate'] as String?,
      politicalParty: json['politicalParty'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cityId: (json['cityId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'name': name,
        'lastName': lastName,
        'startPeriodDate': startPeriodDate,
        'endPeriodDate': endPeriodDate,
        'politicalParty': politicalParty,
        'description': description,
        'cityId': cityId,
      };
}

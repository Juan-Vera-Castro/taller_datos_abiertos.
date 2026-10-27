import 'package:flutter_test/flutter_test.dart';
import 'package:taller_datos_abiertos/models/models.dart';

void main() {
  group('Department', () {
    final json = {
      'id': 3,
      'name': 'Arauca',
      'description': 'Departamento de la Orinoquía',
      'cityCapitalId': 143,
      'municipalities': 7,
      'surface': 23818,
      'population': 304978,
      'phonePrefix': '7',
      'countryId': 1,
      'cityCapital': {
        'id': 143,
        'name': 'Arauca',
        'description': 'Capital del departamento',
        'surface': 5841,
        'population': 96814,
        'postalCode': '810001',
        'departmentId': 3,
        'department': null,
      },
      'regionId': 3,
      'region': null,
    };

    test('fromJson lee campos y ciudad capital anidada', () {
      final d = Department.fromJson(json);
      expect(d.name, 'Arauca');
      expect(d.population, 304978);
      expect(d.cityCapital?.postalCode, '810001');
    });

    test('toJson conserva los datos', () {
      final d = Department.fromJson(Department.fromJson(json).toJson());
      expect(d.cityCapital?.name, 'Arauca');
      expect(d.municipalities, 7);
    });
  });

  group('President', () {
    test('acepta endPeriodDate nulo', () {
      final p = President.fromJson({
        'id': 1,
        'image': 'https://example.com/p.jpg',
        'name': 'Gustavo',
        'lastName': 'Petro',
        'startPeriodDate': '2022-08-07',
        'endPeriodDate': null,
        'politicalParty': 'Colombia Humana',
        'description': 'Presidente',
        'cityId': 1,
        'city': null,
      });
      expect(p.fullName, 'Gustavo Petro');
      expect(p.period, '2022-08-07 — Actualidad');
      expect(President.fromJson(p.toJson()).endPeriodDate, isNull);
    });
  });

  group('TouristicAttraction', () {
    test('fromJson lee imágenes, coordenadas y ciudad', () {
      final t = TouristicAttraction.fromJson({
        'id': 36,
        'name': 'Hacienda Nápoles',
        'description': 'Parque temático',
        'images': ['https://example.com/a.jpg'],
        'latitude': '5.887894',
        'longitude': '-74.6418',
        'cityId': 88,
        'city': {
          'id': 88,
          'name': 'Puerto Triunfo',
          'description': '',
          'surface': null,
          'population': null,
          'postalCode': null,
          'departmentId': 2,
          'touristAttractions': [null],
        },
      });
      expect(t.images, hasLength(1));
      expect(t.latitude, '5.887894');
      expect(t.city?.name, 'Puerto Triunfo');
      expect(t.city?.population, isNull);
      expect(TouristicAttraction.fromJson(t.toJson()).city?.id, 88);
    });
  });

  group('TypicalDish', () {
    test('fromJson lee departamento y separa ingredientes', () {
      final dish = TypicalDish.fromJson({
        'id': 1,
        'name': 'Bandeja Paisa',
        'description': 'Plato emblemático',
        'ingredients': 'Frijoles, arroz, huevo.',
        'imageUrl': 'https://example.com/b.jpg',
        'departmentId': 2,
        'department': {'id': 2, 'name': 'Antioquia', 'description': ''},
      });
      expect(dish.department?.name, 'Antioquia');
      expect(dish.ingredientList, ['Frijoles', 'arroz', 'huevo']);
      expect(TypicalDish.fromJson(dish.toJson()).department?.id, 2);
    });
  });
}

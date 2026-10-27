import 'package:flutter/material.dart';

import '../../models/typical_dish.dart';
import '../../services/typical_dish_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/async_state_builder.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/formatters.dart';

class DishDetailView extends StatelessWidget {
  final int id;
  final TypicalDishService? service;

  const DishDetailView({super.key, required this.id, this.service});

  @override
  Widget build(BuildContext context) {
    final service = this.service ?? TypicalDishService();
    return Scaffold(
      appBar: AppBar(title: const Text('Plato típico')),
      body: AsyncStateBuilder<TypicalDish>(
        loader: () => service.getById(id),
        builder: (context, d, _) => _DishDetail(dish: d),
      ),
    );
  }
}

class _DishDetail extends StatelessWidget {
  final TypicalDish dish;

  const _DishDetail({required this.dish});

  @override
  Widget build(BuildContext context) {
    final d = dish;
    final department = d.department;
    final theme = Theme.of(context);
    return DetailBody(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AppNetworkImage(
            url: d.imageUrl,
            height: 240,
            width: double.infinity,
            targetWidth: 960,
            placeholderIcon: Icons.restaurant_menu,
          ),
        ),
        const SizedBox(height: 16),
        Text(d.name,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        if (department != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18),
              const SizedBox(width: 4),
              Text(department.name, style: theme.textTheme.titleSmall),
            ],
          ),
        ],
        const DetailSectionTitle('Descripción'),
        Text(Formatters.text(d.description), style: theme.textTheme.bodyLarge),
        const DetailSectionTitle('Ingredientes'),
        if (d.ingredientList.isEmpty)
          const Text('Sin dato')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ingredient in d.ingredientList)
                Chip(label: Text(ingredient)),
            ],
          ),
        if (department != null) ...[
          DetailSectionTitle('Departamento: ${department.name}'),
          InfoGrid(tiles: [
            InfoTile(
                icon: Icons.groups_outlined,
                label: 'Población',
                value: '${Formatters.number(department.population)} habitantes'),
            InfoTile(
                icon: Icons.square_foot,
                label: 'Superficie',
                value: '${Formatters.number(department.surface)} km²'),
            InfoTile(
                icon: Icons.location_city_outlined,
                label: 'Municipios',
                value: Formatters.number(department.municipalities)),
            InfoTile(
                icon: Icons.tag,
                label: 'ID plato / departamento',
                value: '${d.id} / ${department.id}'),
          ]),
        ],
      ],
    );
  }
}

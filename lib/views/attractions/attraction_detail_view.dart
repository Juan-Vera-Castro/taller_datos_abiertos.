import 'package:flutter/material.dart';

import '../../models/touristic_attraction.dart';
import '../../services/touristic_attraction_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/async_state_builder.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/formatters.dart';

class AttractionDetailView extends StatelessWidget {
  final int id;
  final TouristicAttractionService? service;

  const AttractionDetailView({super.key, required this.id, this.service});

  @override
  Widget build(BuildContext context) {
    final service = this.service ?? TouristicAttractionService();
    return Scaffold(
      appBar: AppBar(title: const Text('Atractivo turístico')),
      body: AsyncStateBuilder<TouristicAttraction>(
        loader: () => service.getById(id),
        builder: (context, a, _) => _AttractionDetail(attraction: a),
      ),
    );
  }
}

class _AttractionDetail extends StatelessWidget {
  final TouristicAttraction attraction;

  const _AttractionDetail({required this.attraction});

  @override
  Widget build(BuildContext context) {
    final a = attraction;
    final city = a.city;
    final theme = Theme.of(context);
    return DetailBody(
      children: [
        _Gallery(images: a.images),
        const SizedBox(height: 16),
        Text(a.name,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        if (city != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18),
              const SizedBox(width: 4),
              Text(city.name, style: theme.textTheme.titleSmall),
            ],
          ),
        ],
        const DetailSectionTitle('Descripción'),
        Text(Formatters.text(a.description), style: theme.textTheme.bodyLarge),
        const DetailSectionTitle('Ubicación'),
        InfoGrid(tiles: [
          InfoTile(
              icon: Icons.north,
              label: 'Latitud',
              value: Formatters.text(a.latitude)),
          InfoTile(
              icon: Icons.east,
              label: 'Longitud',
              value: Formatters.text(a.longitude)),
          InfoTile(
              icon: Icons.location_city_outlined,
              label: 'Ciudad',
              value: city == null
                  ? 'ID ${a.cityId ?? 'Sin dato'}'
                  : '${city.name} (ID ${city.id})'),
          if (city?.departmentId != null)
            InfoTile(
                icon: Icons.map_outlined,
                label: 'ID departamento',
                value: '${city!.departmentId}'),
        ]),
        if (city != null && city.description.isNotEmpty) ...[
          DetailSectionTitle('Sobre ${city.name}'),
          Text(city.description, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}

/// Muestra la imagen principal o un carrusel si hay varias.
class _Gallery extends StatelessWidget {
  final List<String> images;

  const _Gallery({required this.images});

  @override
  Widget build(BuildContext context) {
    const height = 240.0;
    Widget image(String? url) => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AppNetworkImage(
            url: url,
            height: height,
            width: double.infinity,
            targetWidth: 960,
            placeholderIcon: Icons.landscape_outlined,
          ),
        );

    if (images.length <= 1) {
      return image(images.isEmpty ? null : images.first);
    }
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        itemCount: images.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: image(images[i]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/president.dart';
import '../../services/president_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/async_state_builder.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/formatters.dart';

class PresidentDetailView extends StatelessWidget {
  final int id;
  final PresidentService? service;

  const PresidentDetailView({super.key, required this.id, this.service});

  @override
  Widget build(BuildContext context) {
    final service = this.service ?? PresidentService();
    return Scaffold(
      appBar: AppBar(title: const Text('Presidente')),
      body: AsyncStateBuilder<President>(
        loader: () => service.getById(id),
        builder: (context, p, _) => _PresidentDetail(president: p),
      ),
    );
  }
}

class _PresidentDetail extends StatelessWidget {
  final President president;

  const _PresidentDetail({required this.president});

  @override
  Widget build(BuildContext context) {
    final p = president;
    final theme = Theme.of(context);
    return DetailBody(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AppNetworkImage(
              url: p.image,
              width: 200,
              height: 260,
              targetWidth: 500,
              placeholderIcon: Icons.person_outline,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(p.fullName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(p.politicalParty,
            textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
        const DetailSectionTitle('Periodo de gobierno'),
        InfoGrid(tiles: [
          InfoTile(
              icon: Icons.event_available_outlined,
              label: 'Inicio',
              value: Formatters.date(p.startPeriodDate)),
          InfoTile(
              icon: Icons.event_busy_outlined,
              label: 'Fin',
              value: Formatters.date(p.endPeriodDate)),
          InfoTile(
              icon: Icons.flag_outlined,
              label: 'Partido político',
              value: Formatters.text(p.politicalParty)),
          InfoTile(
              icon: Icons.place_outlined,
              label: 'Ciudad de nacimiento',
              value: p.city?.name ?? 'Sin dato'),
          InfoTile(
              icon: Icons.tag,
              label: 'ID presidente / ciudad',
              value: '${p.id} / ${p.cityId ?? 'Sin dato'}'),
        ]),
        if (p.city != null && p.city!.description.isNotEmpty) ...[
          DetailSectionTitle('Sobre ${p.city!.name}'),
          Text(p.city!.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          InfoGrid(tiles: [
            InfoTile(
                icon: Icons.groups_outlined,
                label: 'Población',
                value: Formatters.number(p.city!.population)),
            InfoTile(
                icon: Icons.square_foot,
                label: 'Superficie',
                value: p.city!.surface == null
                    ? 'Sin dato'
                    : '${Formatters.number(p.city!.surface)} km²'),
          ]),
        ],
        const DetailSectionTitle('Biografía'),
        Text(Formatters.text(p.description), style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

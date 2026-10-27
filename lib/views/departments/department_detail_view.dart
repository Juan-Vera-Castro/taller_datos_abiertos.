import 'package:flutter/material.dart';

import '../../models/department.dart';
import '../../services/department_service.dart';
import '../../widgets/async_state_builder.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/formatters.dart';

class DepartmentDetailView extends StatelessWidget {
  final int id;
  final DepartmentService? service;

  const DepartmentDetailView({super.key, required this.id, this.service});

  @override
  Widget build(BuildContext context) {
    final service = this.service ?? DepartmentService();
    return Scaffold(
      appBar: AppBar(title: const Text('Departamento')),
      body: AsyncStateBuilder<Department>(
        loader: () => service.getById(id),
        builder: (context, d, _) => _DepartmentDetail(department: d),
      ),
    );
  }
}

class _DepartmentDetail extends StatelessWidget {
  final Department department;

  const _DepartmentDetail({required this.department});

  @override
  Widget build(BuildContext context) {
    final d = department;
    final capital = d.cityCapital;
    final theme = Theme.of(context);
    return DetailBody(
      children: [
        Text(d.name,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(Formatters.text(d.description), style: theme.textTheme.bodyLarge),
        const DetailSectionTitle('Datos generales'),
        InfoGrid(tiles: [
          InfoTile(
              icon: Icons.groups_outlined,
              label: 'Población',
              value: '${Formatters.number(d.population)} habitantes'),
          InfoTile(
              icon: Icons.square_foot,
              label: 'Superficie',
              value: '${Formatters.number(d.surface)} km²'),
          InfoTile(
              icon: Icons.location_city_outlined,
              label: 'Municipios',
              value: Formatters.number(d.municipalities)),
          InfoTile(
              icon: Icons.phone_outlined,
              label: 'Indicativo telefónico',
              value: Formatters.text(d.phonePrefix)),
          InfoTile(
              icon: Icons.tag,
              label: 'ID departamento / región',
              value: '${d.id} / ${d.regionId ?? 'Sin dato'}'),
        ]),
        if (capital != null) ...[
          DetailSectionTitle('Capital: ${capital.name}'),
          if (capital.description.isNotEmpty) ...[
            Text(capital.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
          ],
          InfoGrid(tiles: [
            InfoTile(
                icon: Icons.groups_outlined,
                label: 'Población',
                value: Formatters.number(capital.population)),
            InfoTile(
                icon: Icons.square_foot,
                label: 'Superficie',
                value: capital.surface == null
                    ? 'Sin dato'
                    : '${Formatters.number(capital.surface)} km²'),
            InfoTile(
                icon: Icons.markunread_mailbox_outlined,
                label: 'Código postal',
                value: Formatters.text(capital.postalCode)),
          ]),
        ],
      ],
    );
  }
}

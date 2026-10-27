import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/president.dart';
import '../../routes/app_routes.dart';
import '../../services/president_service.dart';
import '../../themes/app_colors.dart';
import '../../widgets/formatters.dart';
import '../../widgets/resource_tile.dart';
import '../resource_list_view.dart';

class PresidentListView extends StatelessWidget {
  final PresidentService? service;

  const PresidentListView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    final service = this.service ?? PresidentService();
    return ResourceListView<President>(
      title: 'Presidentes',
      // Del más reciente al más antiguo.
      loader: () async => (await service.getAll())
        ..sort((a, b) => b.startPeriodDate.compareTo(a.startPeriodDate)),
      searchText: (p) => '${p.fullName} ${p.politicalParty}',
      itemBuilder: (context, p) => ResourceTile(
        title: p.fullName,
        subtitle: '${Formatters.date(p.startPeriodDate)} — '
            '${Formatters.date(p.endPeriodDate)}\n${p.politicalParty}',
        imageUrl: p.image,
        icon: Icons.person_outline,
        color: AppColors.presidents,
        onTap: () => context.goNamed(
          AppRoutes.presidentDetail,
          pathParameters: {AppRoutes.idParam: '${p.id}'},
        ),
      ),
    );
  }
}

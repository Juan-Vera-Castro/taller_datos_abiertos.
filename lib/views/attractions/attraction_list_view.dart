import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/touristic_attraction.dart';
import '../../routes/app_routes.dart';
import '../../services/touristic_attraction_service.dart';
import '../../themes/app_colors.dart';
import '../../widgets/resource_tile.dart';
import '../resource_list_view.dart';

class AttractionListView extends StatelessWidget {
  final TouristicAttractionService? service;

  const AttractionListView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    final service = this.service ?? TouristicAttractionService();
    return ResourceListView<TouristicAttraction>(
      title: 'Atractivos turísticos',
      loader: () async =>
          (await service.getAll())..sort((a, b) => a.name.compareTo(b.name)),
      searchText: (a) => '${a.name} ${a.city?.name ?? ''}',
      itemBuilder: (context, a) => ResourceTile(
        title: a.name,
        subtitle: a.city?.name,
        imageUrl: a.images.isEmpty ? null : a.images.first,
        icon: Icons.landscape_outlined,
        color: AppColors.attractions,
        onTap: () => context.goNamed(
          AppRoutes.attractionDetail,
          pathParameters: {AppRoutes.idParam: '${a.id}'},
        ),
      ),
    );
  }
}

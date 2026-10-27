import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/department.dart';
import '../../routes/app_routes.dart';
import '../../services/department_service.dart';
import '../../themes/app_colors.dart';
import '../../widgets/formatters.dart';
import '../../widgets/resource_tile.dart';
import '../resource_list_view.dart';

class DepartmentListView extends StatelessWidget {
  final DepartmentService? service;

  const DepartmentListView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    final service = this.service ?? DepartmentService();
    return ResourceListView<Department>(
      title: 'Departamentos',
      loader: () async =>
          (await service.getAll())..sort((a, b) => a.name.compareTo(b.name)),
      searchText: (d) => '${d.name} ${d.cityCapital?.name ?? ''}',
      itemBuilder: (context, d) => ResourceTile(
        title: d.name,
        subtitle: [
          if (d.cityCapital != null) 'Capital: ${d.cityCapital!.name}',
          '${Formatters.number(d.population)} hab.',
        ].join(' · '),
        icon: Icons.map_outlined,
        color: AppColors.departments,
        onTap: () => context.goNamed(
          AppRoutes.departmentDetail,
          pathParameters: {AppRoutes.idParam: '${d.id}'},
        ),
      ),
    );
  }
}

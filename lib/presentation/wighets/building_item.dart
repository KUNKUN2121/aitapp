import 'package:aitapp/application/state/building_probvider.dart';
import 'package:aitapp/domain/types/building_info.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BuildingItem extends ConsumerWidget {
  const BuildingItem({super.key, required this.building});
  final BuildingInfo building;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (building.mapShape != null) {
              ref.read(shapeProvider.notifier).state = building;
            }
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            width: double.infinity,
            child: Text(building.name),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class BuildingItem extends StatelessWidget {
  const BuildingItem({super.key, required this.building});
  final String building;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {},
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            width: double.infinity,
            child: Text(building),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

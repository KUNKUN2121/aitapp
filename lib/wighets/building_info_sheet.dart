import 'package:aitapp/const.dart';
import 'package:aitapp/provider/building_probvider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BuildingInfoSheet extends ConsumerWidget {
  const BuildingInfoSheet({super.key, required this.controller});
  final DraggableScrollableController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectShape = ref.watch(shapeProvider);
    final selectBuilding =
        selectShape != null ? buildings[selectShape.id - 1] : null;

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.4,
      minChildSize: 0.15,
      maxChildSize: 0.50,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        selectBuilding?.name ?? '建物を選択',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (selectBuilding != null &&
                        selectBuilding.classrooms != null) ...{
                      for (final floor in selectBuilding.classrooms!.keys) ...{
                        // ignore: prefer_const_constructors
                        Divider(
                          height: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              Text(
                                floor,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: GridView.count(
                                  padding: const EdgeInsets.all(8),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 4,
                                  children: [
                                    for (final classroom in selectBuilding
                                        .classrooms![floor]!) ...{
                                      Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(5),
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          classroom,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    },
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      },
                    },
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:aitapp/provider/building_probvider.dart';
import 'package:aitapp/wighets/map_render.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CampusMap extends HookConsumerWidget {
  const CampusMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectBuilding = ref.watch(buildingProvider);
    final selectShape = ref.watch(shapeProvider);

    final initialMatrix = useMemoized(
      () => Matrix4.translationValues(-250, -750, 0).scaled(2.6),
    );
    final controller = useMemoized(DraggableScrollableController.new);
    final transformationController = useMemoized(
      () => TransformationController(initialMatrix),
    );
    final pixel = useState<double>(200);
    final controllerReset = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    Animation<Matrix4>? animationReset;

    void onAnimateReset() {
      transformationController.value = animationReset!.value;
      if (!controllerReset.isAnimating) {
        animationReset!.removeListener(onAnimateReset);
        animationReset = null;
        controllerReset.reset();
      }
    }

    useEffect(
      () {
        controller.addListener(() {
          pixel.value = controller.pixels + 10;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.watch(buildingProvider.notifier).state = null;
          ref.watch(shapeProvider.notifier).state = null;
          pixel.value = controller.pixels + 10;
        });
        return null;
      },
      [],
    );

    void animateResetInitialize(Matrix4 destination) {
      if (!controllerReset.isAnimating) {
        controllerReset.reset();
        animationReset = Matrix4Tween(
          begin: transformationController.value,
          end: destination,
        ).chain(CurveTween(curve: Curves.decelerate)).animate(controllerReset);
        animationReset!.addListener(onAnimateReset);
        controllerReset.forward();
      }
    }

    if (selectShape != null) {
      final bounds = selectShape.transformedPath!.getBounds();
      final centerX = bounds.left + bounds.width / 2;
      final centerY = bounds.top + bounds.height / 2;
      animateResetInitialize(
        Matrix4.translationValues(-centerX * 7.0 + 200, -centerY * 7.0 + 250, 0)
            .scaled(7.0),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'マップ',
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: transformationController,
            maxScale: 15,
            minScale: 2,
            child: const SVGMap(),
          ),
          Positioned(
            bottom: pixel.value,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                animateResetInitialize(initialMatrix);
              },
              child: const Icon(Icons.home),
            ),
          ),
          DraggableScrollableSheet(
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
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
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
                    ),
                    SliverList.list(
                      children: [
                        const SizedBox(height: 12),
                        Center(
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
                          for (final floor
                              in selectBuilding.classrooms!.keys) ...{
                            // ignore: prefer_const_constructors
                            Divider(
                              height: 1,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Text(
                                    floor,
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: GridView.count(
                                      padding: const EdgeInsets.all(8),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
                                              style:
                                                  const TextStyle(fontSize: 12),
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
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

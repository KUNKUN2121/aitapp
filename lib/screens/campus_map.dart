import 'package:aitapp/wighets/map_render.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CampusMap extends HookWidget {
  const CampusMap({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(DraggableScrollableController.new);
    final transformationController = useMemoized(
      () => TransformationController(
        Matrix4(
          2.69,
          0,
          0,
          0,
          0,
          2.69,
          0,
          0,
          0,
          0,
          2.69,
          0,
          -250,
          -750,
          0,
          1,
        ),
      ),
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
          pixel.value = controller.pixels + 10;
        });
        return null;
      },
      [],
    );

    void animateResetInitialize() {
      controllerReset.reset();
      animationReset = Matrix4Tween(
        begin: transformationController.value,
        end: Matrix4(
          2.69,
          0,
          0,
          0,
          0,
          2.69,
          0,
          0,
          0,
          0,
          2.69,
          0,
          -250,
          -750,
          0,
          1,
        ),
      ).animate(controllerReset);
      animationReset!.addListener(onAnimateReset);
      controllerReset.forward();
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
              onPressed: animateResetInitialize,
              child: const Icon(Icons.home),
            ),
          ),
          DraggableScrollableSheet(
            controller: controller,
            initialChildSize: 0.3,
            minChildSize: 0.1,
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
                      children: const [
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Pull up to expand',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        // 追加のコンテンツを配置
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

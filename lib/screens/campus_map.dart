import 'package:aitapp/wighets/map_render.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CampusMap extends HookWidget {
  const CampusMap({super.key});

  @override
  Widget build(BuildContext context) {
    final transformationController = TransformationController();
    final controllerReset = useAnimationController(
      duration: const Duration(milliseconds: 400),
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

    void animateResetInitialize() {
      controllerReset.reset();
      animationReset = Matrix4Tween(
        begin: transformationController.value,
        end: Matrix4.identity(),
      ).animate(controllerReset);
      animationReset!.addListener(onAnimateReset);
      controllerReset.forward();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'マップ',
        ),
      ),
      body: InteractiveViewer(
        transformationController: transformationController,
        maxScale: 15,
        minScale: 0.1,
        child: const SVGMap(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: animateResetInitialize,
        child: const Icon(
          Icons.home_filled,
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class OpenFileImage extends HookConsumerWidget {
  const OpenFileImage({
    super.key,
    required this.title,
    required this.file,
  });

  final String title;
  final File file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transformationController = useTransformationController();
    final isSharefile = useState(false);
    final doubleTapDetails = useRef<TapDownDetails?>(null);
    void handleDoubleTap() {
      if (transformationController.value != Matrix4.identity()) {
        transformationController.value = Matrix4.identity();
      } else {
        final position = doubleTapDetails.value!.localPosition;
        // For a 3x zoom
        transformationController.value = Matrix4.identity()
          ..translate(-position.dx, -position.dy)
          ..scale(2.0);
        // Fox a 2x zoom
        // ..translate(-position.dx, -position.dy)
        // ..scale(2.0);
      }
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: isSharefile.value
                ? null
                : () async {
                    isSharefile.value = true;
                    await Share.shareXFiles([XFile(file.path)]);
                    isSharefile.value = false;
                  },
          ),
        ],
      ),
      body: GestureDetector(
        onDoubleTapDown: (d) => doubleTapDetails.value = d,
        onDoubleTap: handleDoubleTap,
        child: SizedBox.expand(
          child: InteractiveViewer(
            transformationController: transformationController,
            maxScale: 2,
            child: Image.file(
              file,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

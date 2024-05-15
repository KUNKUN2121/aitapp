import 'dart:ui';

import 'package:flutter/material.dart';

class BuildSection extends StatelessWidget {
  const BuildSection({super.key, required this.title, required this.content});

  final String title;
  final List<String> content;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 30,
        ),
        for (final text in content)
          SelectableText(text, selectionHeightStyle: BoxHeightStyle.max),
      ],
    );
  }
}

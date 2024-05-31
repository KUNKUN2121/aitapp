import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 25, //指定
        width: 25, //指定
        child: CircularProgressIndicator(),
      ),
    );
  }
}

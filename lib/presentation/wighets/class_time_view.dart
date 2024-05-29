import 'package:flutter/material.dart';

// 授業時間表示
class ClassTimeView extends StatelessWidget {
  const ClassTimeView({
    super.key,
    required this.start,
    required this.end,
    required this.number,
  });
  final String start;
  final String end;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      margin: const EdgeInsets.all(2),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            start,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // color: Colors.grey,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
          Text(
            end,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

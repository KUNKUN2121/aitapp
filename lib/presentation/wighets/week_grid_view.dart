// 曜日表示
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:flutter/material.dart';

class WeekGridContainer extends StatelessWidget {
  const WeekGridContainer({super.key, required this.dayofweek});
  final DayOfWeek dayofweek;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      margin: const EdgeInsets.all(2),
      height: 35,
      child: Text(
        dayofweek.displayName,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
      ),
    );
  }
}

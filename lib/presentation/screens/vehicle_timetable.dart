import 'package:aitapp/presentation/wighets/vehicle_timetable_item.dart';
import 'package:flutter/material.dart';

class TimeTableScreen extends StatelessWidget {
  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        children: [
          TimeTableColumn(
            vehicle: 'bus',
            destination: 'toAIT',
          ),
          TimeTableColumn(
            vehicle: 'bus',
            destination: 'toYakusa',
          ),
        ],
      ),
    );
  }
}

import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/presentation/screens/timetable_detail.dart';
import 'package:aitapp/presentation/wighets/timetable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class TimeTableColumn extends HookWidget {
  const TimeTableColumn({
    super.key,
    required this.vehicle,
    required this.destination,
  });
  final String vehicle;
  final String destination;

  @override
  Widget build(BuildContext context) {
    final now =
        useMemoized(() => DateTime.now().toUtc().add(const Duration(hours: 9)));
    final todayDaiya = useMemoized(
      () => dayDaiya[DateFormat('yyyy-MM-dd').format(now)],
    );
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vehicleName[vehicle]! + destinationName[destination]!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (ctx) => TimeTableDetailScreen(
                        vehicle: vehicle,
                        destination: destination,
                      ),
                    ),
                  );
                },
                child: const Text(
                  '時刻表を見る',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          todayDaiya != null && todayDaiya != '-'
              ? Expanded(
                  child: ListView(
                    children: List.generate(
                      3, // 表示する TimeCard の数
                      (index) => Column(
                        children: [
                          if (index > 0) const SizedBox(height: 10),
                          TimeCard(
                            vehicle: vehicle,
                            destination: destination,
                            order: index,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text('運行はありません'),
                ),
        ],
      ),
    );
  }
}

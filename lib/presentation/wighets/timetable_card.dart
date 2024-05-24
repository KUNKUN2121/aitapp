import 'dart:async';

import 'package:aitapp/domain/features/next_departure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class TimeCard extends HookWidget {
  const TimeCard({
    super.key,
    required this.vehicle,
    required this.destination,
    required this.order,
  });
  final String vehicle;
  final String destination;
  final int order;

  @override
  Widget build(BuildContext context) {
    final f = useMemoized(() => DateFormat('HH:mm'));
    final nextDepartureTime = useState<DateTime?>(null);
    final time = useState<DateTime?>(null);
    final timer = useRef<Timer?>(null);

    void reflashtime() {
      nextDepartureTime.value = NextDeparture(
        vehicle: vehicle,
        destination: destination,
        order: order,
      ).searchNextDeparture();
    }

    useEffect(
      () {
        nextDepartureTime.value = NextDeparture(
          vehicle: vehicle,
          destination: destination,
          order: order,
        ).searchNextDeparture();
        time.value = DateTime.now().toUtc().add(const Duration(hours: 9));
        timer.value =
            Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          time.value = DateTime.now().toUtc().add(const Duration(hours: 9));
        });
        return () {
          timer.value!.cancel();
        };
      },
    );
    if (nextDepartureTime.value != null) {
      final remainTime = nextDepartureTime.value!.difference(time.value!);
      if (remainTime.inSeconds % 60 == 0 && remainTime.inMinutes % 5 == 0) {
        reflashtime();
      }
      final remainHour =
          remainTime.inMinutes < 60 ? '' : '${remainTime.inHours}時間';
      final remainMinutes =
          remainTime.inSeconds < 60 ? '' : '${remainTime.inMinutes % 60}分';
      final remainSeconds = '${remainTime.inSeconds % 60}秒';
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).canvasColor,
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'あと$remainHour$remainMinutes$remainSeconds',
                  style: const TextStyle(
                    // color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Text(
              f.format(nextDepartureTime.value!),
              style: const TextStyle(
                // color: Colors.black,
                fontSize: 48,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }
}

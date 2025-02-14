import 'package:aitapp/application/config/const.dart';
import 'package:intl/intl.dart';

class NextDeparture {
  NextDeparture({
    required this.vehicle,
    required this.destination,
    required this.order,
  });
  final String vehicle;
  final String destination;
  final int order;
  DateTime? searchNextDeparture() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    final todayDaiyaAlphabet = dayDaiya[DateFormat('yyyy-MM-dd').format(now)];
    if (todayDaiyaAlphabet == null || todayDaiyaAlphabet == '-') {
      return null;
    }
    var counter = 0;
    final todayDaiya = daiya[vehicle]?[destination]?[todayDaiyaAlphabet];

    final hours = todayDaiya!.keys;
    for (final hour in hours) {
      final minutes = todayDaiya[hour];
      if (hour >= now.hour && minutes != null) {
        for (final minute in minutes) {
          if (minute > now.minute || hour > now.hour) {
            if (order == counter) {
              return DateTime.utc(now.year, now.month, now.day, hour, minute);
            } else {
              counter++;
            }
          }
        }
      }
    }
    return null;
  }
}

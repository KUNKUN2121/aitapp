import 'package:aitapp/domain/features/lcam_parce.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/infrastructure/restaccess/access_lcan.dart';

class GetClassTimeTable {
  final parse = LcamParse();
  Future<Map<DayOfWeek, Map<int, Class>>> getClassTimeTable(
    String id,
    String password,
  ) async {
    final cookies = await getCookie();
    await loginLcam(id: id, password: password, cookies: cookies);
    final body = await getClassTimeTableBody(cookies: cookies);
    return parse.classTimeTable(body);
  }
}

import 'package:aitapp/domain/types/notice.dart';

class UnivNotice extends Notice {
  UnivNotice({
    required super.sender,
    required super.title,
    required super.isInportant,
    required this.sendAt,
  });
  // 送信日時
  final String sendAt;
}

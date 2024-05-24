import 'package:aitapp/domain/types/notice.dart';

// 学内お知らせ
class UnivNotice extends Notice {
  UnivNotice({
    required super.sender,
    required super.title,
    required super.isInportant,
    required super.index,
    required this.sendAt,
  });
  // 送信日時
  final String sendAt;
}

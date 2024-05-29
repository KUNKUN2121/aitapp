import 'package:aitapp/domain/types/notice.dart';

// 学内お知らせ
class UnivNotice implements Notice {
  UnivNotice({
    required this.sender,
    required this.title,
    required this.isInportant,
    required this.index,
    required this.sendAt,
  });
  // 送信日時
  final String sendAt;
  // 発信者
  @override
  final String sender;
  // タイトル
  @override
  final String title;
  // 重要かどうか
  @override
  final bool isInportant;
  // インデックス
  @override
  final int index;
}

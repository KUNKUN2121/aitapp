import 'package:aitapp/domain/types/notice.dart';

// 授業お知らせ
class ClassNotice implements Notice {
  ClassNotice({
    required this.sender,
    required this.title,
    required this.isInportant,
    required this.index,
    required this.subject,
    this.makeupClassAt,
  });
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
  // 教科
  final String subject;
  // 補講日日付
  final String? makeupClassAt;
}

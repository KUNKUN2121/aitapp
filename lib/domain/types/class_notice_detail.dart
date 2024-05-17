import 'package:aitapp/domain/types/notice_detail.dart';

// 授業お知らせ詳細
class ClassNoticeDetail extends NoticeDetail {
  ClassNoticeDetail({
    required super.sender,
    required super.title,
    required super.sendAt,
    required super.content,
    required this.subject,
    required super.url,
    required super.files,
    this.makeupClassAt,
  });

  // 教科
  final String subject;
  // 補講日日付
  final String? makeupClassAt;
}

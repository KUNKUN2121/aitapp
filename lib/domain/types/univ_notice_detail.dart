import 'package:aitapp/domain/types/notice_detail.dart';

// 学内お知らせ詳細
class UnivNoticeDetail extends NoticeDetail {
  UnivNoticeDetail({
    required super.sender,
    required super.title,
    required super.sendAt,
    required super.content,
    required super.url,
    required super.files,
  });
}

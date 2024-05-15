import 'package:aitapp/domain/types/notice_detail.dart';

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

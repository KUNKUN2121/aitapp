import 'package:aitapp/domain/types/notice_detail.dart';

// 授業お知らせ詳細
class ClassNoticeDetail implements NoticeDetail {
  ClassNoticeDetail({
    required this.sender,
    required this.title,
    required this.sendAt,
    required this.content,
    required this.subject,
    required this.url,
    required this.files,
    this.makeupClassAt,
  });
  // 発信者
  @override
  final String sender;
  // タイトル
  @override
  final String title;
  // 内容
  @override
  final String content;
  // url
  @override
  final List<String> url;
  // ファイルurl
  @override
  final Map<String, String> files;
  // 送信日時
  @override
  final String sendAt;
  // 教科
  final String subject;
  // 補講日日付
  final String? makeupClassAt;
}

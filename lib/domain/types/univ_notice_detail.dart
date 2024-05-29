import 'package:aitapp/domain/types/notice_detail.dart';

// 学内お知らせ詳細
class UnivNoticeDetail implements NoticeDetail {
  UnivNoticeDetail({
    required this.sender,
    required this.title,
    required this.sendAt,
    required this.content,
    required this.url,
    required this.files,
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
}

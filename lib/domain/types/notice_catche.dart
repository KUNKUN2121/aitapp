import 'package:aitapp/domain/types/notice.dart';

class NoticeCatche {
  NoticeCatche({
    required this.page,
    required this.notices,
    required this.token,
    this.isLast = false,
  });
  final int page;
  final List<Notice> notices;

  /// この一覧フローの現在のStrutsトークン。詳細取得(goDetail)や次ページ取得は
  /// このトークンを起点にする。授業連絡/学内連絡でキャッシュが分かれているため、
  /// トークンも種別ごとに独立して持てる。
  final String token;
  final bool isLast;
}

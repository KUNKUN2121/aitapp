import 'package:aitapp/domain/types/notice.dart';

class NoticeCatche {
  NoticeCatche({
    required this.page,
    required this.notices,
    this.isLast = false,
  });
  final int page;
  final List<Notice> notices;
  final bool isLast;
}

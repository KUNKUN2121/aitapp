import 'package:aitapp/domain/types/notice_catche.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'class_notice.g.dart';

@Riverpod(keepAlive: true)
class ClassNoticesNotifier extends _$ClassNoticesNotifier {
  @override
  NoticeCatche? build() {
    return null;
  }

  void change(NoticeCatche catche) {
    state = catche;
    debugPrint('noticeを書き込みました');
  }
}

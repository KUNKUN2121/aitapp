import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'notice_load.g.dart';

@Riverpod(keepAlive: true)
class NoticeLoadNotifier extends _$NoticeLoadNotifier {
  @override
  bool build() {
    return false;
  }

  void changeState({required bool isload}) {
    debugPrint('ローディングが$isloadになりました');
    state = isload;
  }
}

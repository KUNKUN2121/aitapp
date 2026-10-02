import 'package:aitapp/application/state/link_tap_provider.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'last_login.g.dart';

/// お知らせ一覧の再取得トリガ([LastLogin])を保持する。
///
/// これはセッション制御ではなく「最後に表示したお知らせ種別」の記録で、
/// 画面が別種別に変わったときやアプリ復帰時に一覧を取り直すために使う。
/// セッションの確立・再利用・復帰は `LcamSession` が担う。
@Riverpod(keepAlive: true)
class LastLoginNotifier extends _$LastLoginNotifier {
  late DateTime loginTime;

  // アプリ復帰時、最後の取得から10分以上経過しているかリンクを踏んでいれば、
  // お知らせキャッシュを無効化(others)して次回アクセスで再取得させる。
  void cycleChangeState(AppLifecycleState value) {
    if (value == AppLifecycleState.resumed &&
        (DateTime.now().difference(loginTime) >= const Duration(minutes: 10) ||
            ref.read(linkTapProvider))) {
      state = LastLogin.others;
      ref.read(linkTapProvider.notifier).state = false;
    }
  }

  @override
  LastLogin build() {
    loginTime = DateTime.now();
    final observer = _AppLifecycleObserver(cycleChangeState);
    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(observer);
    });
    return LastLogin.others;
  }

  void changeState(LastLogin loginType) {
    loginTime = DateTime.now();
    state = loginType;
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  _AppLifecycleObserver(this._didChangeState);

  final ValueChanged<AppLifecycleState> _didChangeState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _didChangeState(state);
    super.didChangeAppLifecycleState(state);
  }
}

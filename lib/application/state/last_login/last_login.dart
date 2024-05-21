import 'package:aitapp/application/state/link_tap_provider.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'last_login.g.dart';

@Riverpod(keepAlive: true)
class LastLoginNotifier extends _$LastLoginNotifier {
  late DateTime loginTime;

  // アプリケーションサイクルが変化したときに実行される
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

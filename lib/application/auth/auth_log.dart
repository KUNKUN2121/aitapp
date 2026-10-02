import 'package:flutter/foundation.dart';

/// 認証まわりのイベント種別。JSESSIONID・仮パスワードの実寿命を把握し、
/// 認証エラーの原因(セッション切れ / 仮パス失効)を切り分けるために記録する。
enum AuthEvent {
  /// セッションを新規確立した(getCookie + smartPhoneLogin)。
  establish,

  /// 既存セッションを再利用した(ログインを省略)。
  reuse,

  /// セッションを破棄した(失効検知 / 仮パス更新)。
  invalidate,

  /// 復帰階段: 保存id/仮パスでの再ログインに成功した(JSESSIONID切れだった)。
  recoverRelogin,

  /// 復帰階段: 仮パス失効を検知した(再ログインしても未ログイン)。
  credentialExpired,

  /// 復帰階段: SSO再認証で新しい仮パスを取得して復帰した。
  recoverSso,

  /// 復帰不能。ログイン画面へ誘導した。
  authRequired,

  /// 発行から一定時間が経った仮パスを、アクセス前にサイレント更新した。
  prefetchRefresh,
}

/// 認証イベントの軽量なリングバッファ。直近のイベントを時刻付きで保持する。
///
/// リリースビルドでも記録は残す(メモリ内のみ)。将来、設定画面のデバッグ項目から
/// [entries] をダンプして実寿命の調査に使う。
class AuthLog {
  AuthLog._();

  static const _maxEntries = 200;
  static final List<String> _entries = <String>[];

  static void record(AuthEvent event, [String? detail]) {
    final time = DateTime.now().toIso8601String();
    final line = detail == null
        ? '$time  ${event.name}'
        : '$time  ${event.name}  $detail';
    _entries.add(line);
    if (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }
    debugPrint('[AuthLog] $line');
  }

  /// 記録済みイベント(古い順)。デバッグ表示用。
  static List<String> get entries => List.unmodifiable(_entries);

  static void clear() => _entries.clear();
}

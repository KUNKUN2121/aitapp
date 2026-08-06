import 'dart:io';

import 'package:aitapp/application/usecases/session_reauth.dart';
import 'package:aitapp/presentation/screens/notice_detail_by_path.dart';
import 'package:aitapp/presentation/screens/webview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// デバッグ時のみ有効な、adb からの通知開封テスト用チャンネル。
/// 本物のFCM配信は GMS しか行えず adb からは注入できないため、
/// 通知タップ後の「targetUrl を開く」ロジックだけを
/// サーバー無しで検証できるようにする。詳細は [_setupDebugTestChannel]。
const _testChannel = MethodChannel('aitapp/push_test');

/// FCM(プッシュ通知)の初期化。
///
/// 旧アプリ(Cordova/firebasex)と同じ仕組みで、ログイン中ユーザーの `userId` を
/// 名前にしたトピックを購読する。サーバーは `/topics/<userId>` 宛に送信するため、
/// アプリ側はこのトピックを購読するだけで旧アプリと同じ通知を受け取れる。
///
/// 通知タップ時は payload の `targetUrl` を開く。学内連絡の詳細URLなら
/// お知らせ一覧経由と同じネイティブ整形詳細で、それ以外は認証済み WebView で開く。
///
/// Android専用。iOSはFirebaseの設定(APNs)が無いため何もしない。
Future<void> initPushNotification({String? userId}) async {
  if (!Platform.isAndroid) {
    return;
  }
  // デバッグ時のみ: adb からの通知開封テストを受け付ける
  await _setupDebugTestChannel();
  try {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;

    // Android 13+ の通知許可
    await messaging.requestPermission();

    // ログイン中ユーザーのトピックを購読
    await subscribePushTopic(userId);

    // 終了状態から通知タップで起動した場合
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _handleTap(initial);
    }
    // バックグラウンドからの通知タップ
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
  } on Exception catch (e) {
    debugPrint('initPushNotification failed: $e');
  }
}

/// ログイン中ユーザーの `userId` トピックを購読する。
Future<void> subscribePushTopic(String? userId) async {
  if (!Platform.isAndroid || userId == null || userId.isEmpty) {
    return;
  }
  try {
    await FirebaseMessaging.instance.subscribeToTopic(userId);
  } on Exception catch (e) {
    debugPrint('subscribePushTopic failed: $e');
  }
}

/// ログアウト時などにトピック購読を解除する。
Future<void> unsubscribePushTopic(String? userId) async {
  if (!Platform.isAndroid || userId == null || userId.isEmpty) {
    return;
  }
  try {
    await FirebaseMessaging.instance.unsubscribeFromTopic(userId);
  } on Exception catch (e) {
    debugPrint('unsubscribePushTopic failed: $e');
  }
}

/// デバッグ時のみ、adb からのテスト用ディープリンクで通知開封ロジックを叩けるようにする。
///
/// 本物のFCM配信は Google Play Services しか行えず adb からは注入できないため、
/// 「targetUrl を開く」部分([_openTarget])だけを検証する目的。使い方:
/// ```sh
/// adb shell am start -n com.yoheinishi.aitapp/.MainActivity \
///   --es test_target_url "portalv2/smartphone/.../detail/330848"
/// ```
/// - アプリ終了状態から: MainActivity が起動intentのextraを保持し、Dart が
///   `getInitialTestUrl` で引き取る(コールドスタート経路=本番の getInitialMessage 相当)。
/// - バックグラウンドから: MainActivity.onNewIntent が `openTest` を push する
///   (ウォーム経路=本番の onMessageOpenedApp 相当)。
Future<void> _setupDebugTestChannel() async {
  if (!kDebugMode) {
    return;
  }
  _testChannel.setMethodCallHandler((call) async {
    if (call.method == 'openTest' && call.arguments is String) {
      _openTarget(call.arguments as String);
    }
    return null;
  });
  try {
    final initial =
        await _testChannel.invokeMethod<String>('getInitialTestUrl');
    if (initial != null && initial.isNotEmpty) {
      _openTarget(initial);
    }
  } on PlatformException catch (e) {
    debugPrint('getInitialTestUrl failed: $e');
  }
}

void _handleTap(RemoteMessage message) {
  final data = message.data;
  // 旧アプリは `targetUrl` を使用。念のため他の候補キーもフォールバックで拾う。
  final url = (data['targetUrl'] ??
      data['target_url'] ??
      data['url'] ??
      data['link']) as String?;
  if (url == null || url.isEmpty) {
    debugPrint('[FCM] tap: no url in payload keys=${data.keys.toList()}');
    return;
  }
  _openTarget(url);
}

/// 学内連絡詳細の targetUrl 判定用(例:
/// `smartPhoneCommonContactDetail/detail/330848` / `...ClassContactDetail...`)。
final _noticeDetailPattern =
    RegExp(r'smartPhone(Common|Class)ContactDetail/detail/\d+');

/// `targetUrl`(相対パス or 絶対URL)を適切な画面で開く共通処理。
///
/// 学内連絡の詳細URLなら、お知らせ一覧経由と同じネイティブ整形詳細
/// ([NoticeDetailByPathScreen])で開く。それ以外(アンケート等)は従来どおり
/// 認証済み [WebViewScreen] で開く。
void _openTarget(String url) {
  // targetUrl は相対パス(例: portalv2/...)。WebView/取得処理が内部で
  // `https://$origin$path` を組み立てるため、先頭スラッシュ付きのパスに正規化。
  // 万一 targetUrl が絶対URLの場合はパス部分だけを取り出す。
  final String path;
  if (url.startsWith('http')) {
    final uri = Uri.parse(url);
    path = uri.path + (uri.hasQuery ? '?${uri.query}' : '');
  } else {
    path = url.startsWith('/') ? url : '/$url';
  }

  final match = _noticeDetailPattern.firstMatch(path);
  if (match != null) {
    final isCommon = match.group(1) == 'Common';
    _openWhenReady(
      (_) => NoticeDetailByPathScreen(path: path, isCommon: isCommon),
    );
  } else {
    _openWhenReady((_) => WebViewScreen(url: path, title: 'お知らせ'));
  }
}

/// Navigator が準備できてから [builder] の画面を push する。
///
/// 終了状態から通知タップで起動した直後は `getInitialMessage` が
/// runApp より先に解決し得るため、`navigatorKey.currentState` がまだ null の
/// ことがある。準備できるまで数回リトライしてから遷移する。
Future<void> _openWhenReady(WidgetBuilder builder, {int retry = 0}) async {
  final navigator = navigatorKey.currentState;
  if (navigator == null) {
    if (retry >= 40) {
      debugPrint('[FCM] navigator not ready, give up');
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _openWhenReady(builder, retry: retry + 1);
  }
  await navigator.push(MaterialPageRoute<void>(builder: builder));
}

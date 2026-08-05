import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/link_tap_provider.dart';
import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/domain/types/web_access.dart';
import 'package:aitapp/presentation/screens/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class MainDrawerUseCase {
  MainDrawerUseCase(this.ref, this.context);
  final WidgetRef ref;
  final BuildContext context;

  Future<void> go(Widget widget) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => widget,
      ),
    );
  }

  Future<void> _replaceGo(Widget widget) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (ctx) => widget,
      ),
    );
  }

  Future<void> reLogin(Widget widget) async {
    // 再ログイン: Cookie(Entraセッション)やid/passwordは削除せず、ログイン画面を
    // 表示するだけ。Cookieを保持しているためMicrosoftの認証プロンプトは表示されず、
    // SSO経由で新しいToken(仮パスワード)が再発行され、completeLoginで上書きされる。
    await _replaceGo(widget);
  }

  Future<void> removeIdentity(Widget widget) async {
    final pref = ref.read(sharedPreferencesProvider);
    await pref.remove('id');
    await pref.remove('password');
    await pref.remove('isStaff');
    ref.read(identityProvider.notifier).clear();
    // ログアウト時のみWebViewのCookie(Entraセッション)を削除する。
    // これにより次回ログイン時は再度Microsoftの認証が必要になる。
    await WebviewCookieManager().clearCookies();
    await _replaceGo(widget);
  }

  /// Moodle(PC版)を外部ブラウザで開く。
  /// 従来の自動ログイン(para方式)は使えなくなったため、SAML SSOの
  /// ログインページを開き、サインインはユーザーに委ねる。
  Future<void> openMoodle() async {
    await launchUrl(
      Uri.parse(moodleLoginUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  /// L-Cam(PC版)を外部ブラウザで開く。
  /// 従来の自動ログイン(para方式)は使えなくなったため、SSOログインを
  /// 開始するページを開き、サインインはユーザー(ブラウザのSSOセッション)に委ねる。
  Future<void> loginCampus() async {
    ref.read(linkTapProvider.notifier).state = true;
    await launchUrl(
      mode: LaunchMode.externalApplication,
      Uri.https(origin, '/portalv2/'),
    );
  }

  /// Office 365 (Outlook on the web) を外部ブラウザで開く。
  /// login_hint にログインID(学生:学籍番号@ドメイン / 事務職員:@ドメインのみ)を
  /// 付与することで、ブラウザにSSOセッションがあればアカウント選択を省略できる。
  Future<void> openOffice365() async {
    final pref = ref.read(sharedPreferencesProvider);
    final isStaff = pref.getBool('isStaff') ?? false;
    // 学生の 愛工大ID(=学籍番号)はメールのローカル部と一致するが、事務職員の
    // 事務ID は一致しないため、事務職員はローカル部を空にする。
    final id = ref.read(identityProvider)?.id ?? '';
    final loginHint = '${isStaff ? '' : id}@$aitechMailDomain';
    await launchUrl(
      mode: LaunchMode.externalApplication,
      Uri.https(office365Host, '/', {'login_hint': loginHint}),
    );
  }

  Future<void> openSyllabusSearch(Widget widget) async {
    await go(widget);
    ref.read(selectSyllabusFilterNotifierProvider.notifier).initialize();
  }

  Future<void> openWebView(Widget widget) async {
    await go(widget);
    ref.read(lastLoginNotifierProvider.notifier).changeState(LastLogin.others);
  }

  /// 特定の学内Webページ([WebAccessLink])を直接WebViewで開く。
  /// アンケートなど、一覧を経由せずホームから開く用途で使う。
  Future<void> openWebLink(WebAccessLink link) async {
    await go(WebViewScreen(title: link.title, url: link.url));
    ref.read(lastLoginNotifierProvider.notifier).changeState(LastLogin.others);
  }
}

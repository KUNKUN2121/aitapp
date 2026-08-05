import 'package:aitapp/application/config/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// EntraID SSOのサインイン画面をアプリ内WebViewで表示する。
///
/// サインイン成功時にサーバが `lamyapp://lcam?key=xxxx` へリダイレクトしようと
/// するのを [NavigationDelegate.onNavigationRequest] で横取りし、実際の遷移
/// (OSのディープリンク発火) を行わずに `key` だけを取り出して pop で返す。
///
/// - サインイン成功: `key` (String) を返して pop
/// - ユーザーが戻る/閉じた: null を返して pop
///
/// Cookieは基本的にクリアしない。Entraのセッションを保持することで、仮パスワード
/// が期限切れ(12時間)になった際もMicrosoftの認証プロンプトなしで自動的に
/// 再ログインできる。
///
/// 例外として、蓄積したSSO Cookieでサイレント認証が壊れ、SAML受け口(mellon)が
/// 400を返した場合のみ、その場でCookie/キャッシュを消して対話ログインへ
/// フォールバックする(自己修復。onHttpError を参照)。
class SsoWebViewScreen extends HookWidget {
  const SsoWebViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(true);

    // mellonの400を検知した際の自己修復(Cookieクリア→再試行)は一度だけ行う。
    // 無限ループを防ぐためのガード。
    final hasRecovered = useRef(false);

    final controller = useMemoized(() {
      final webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        // 埋め込みWebViewでのMicrosoftログイン制限を避けるため通常ブラウザのUAを指定
        ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36',
        );
      webController
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              // lamyapp://lcam?key=... への遷移を横取りする
              if (request.url.startsWith('$ssoCallbackScheme://')) {
                final key = Uri.parse(request.url).queryParameters['key'];
                if (context.mounted) {
                  Navigator.of(context).pop(key);
                }
                // 実際には遷移させない (ディープリンクを発火させない)
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageStarted: (_) => isLoading.value = true,
            onPageFinished: (_) => isLoading.value = false,
            // SAML受け口(mod_auth_mellon)で400になるのは、蓄積したMicrosoftの
            // SSO Cookieでサイレント認証が壊れた状態(Apacheが不正リクエストとして
            // 弾く)。この場合はCookie/キャッシュを消して対話ログインからやり直す。
            onHttpError: (error) async {
              final uri = error.response?.uri ?? error.request?.uri;
              if (error.response?.statusCode == 400 &&
                  (uri?.path.contains('/mellon/postResponse') ?? false) &&
                  !hasRecovered.value) {
                hasRecovered.value = true;
                debugPrint('[SSO] mellon 400検知 → Cookie/キャッシュ削除して再試行');
                await WebviewCookieManager().clearCookies();
                await webController.clearCache();
                await webController.clearLocalStorage();
                await webController.loadRequest(Uri.parse(ssoAuthUrl));
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(ssoAuthUrl));
      return webController;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('愛工大アカウントでログイン'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading.value) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

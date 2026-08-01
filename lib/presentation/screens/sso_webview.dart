import 'package:aitapp/application/config/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
/// Cookieは意図的にクリアしない。Entraのセッションを保持することで、仮パスワード
/// が期限切れ(12時間)になった際もMicrosoftの認証プロンプトなしで自動的に
/// 再ログインできる。Cookieの削除はログアウト時のみ行う。
class SsoWebViewScreen extends HookWidget {
  const SsoWebViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(true);

    final controller = useMemoized(() {
      return WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        // 埋め込みWebViewでのMicrosoftログイン制限を避けるため通常ブラウザのUAを指定
        ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36',
        )
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
          ),
        )
        ..loadRequest(Uri.parse(ssoAuthUrl));
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

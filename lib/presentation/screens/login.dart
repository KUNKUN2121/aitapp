import 'package:aitapp/application/usecases/login_usecase.dart';
import 'package:aitapp/infrastructure/restaccess/access_lcan.dart';
import 'package:aitapp/presentation/screens/sso_webview.dart';
import 'package:aitapp/presentation/screens/staff_login.dart';
import 'package:aitapp/presentation/wighets/loading/circular_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> login() async {
      errorMessage.value = null;
      // アプリ内WebViewでSSOサインインを行い、リダイレクトから key を取得する
      final key = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (ctx) => const SsoWebViewScreen(),
        ),
      );
      // ユーザーがサインインをキャンセルした場合は何もしない
      if (key == null || key.isEmpty) {
        return;
      }
      isLoading.value = true;
      try {
        final identity = await ssoExchangeKey(key: key);
        if (!context.mounted) {
          return;
        }
        await completeLogin(context: context, ref: ref, identity: identity);
      } on SsoException catch (e) {
        errorMessage.value = e.message;
        isLoading.value = false;
      } on Exception {
        errorMessage.value = '接続に失敗しました。時間をおいて再度お試しください。';
        isLoading.value = false;
      }
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // アプリのシンボル
                  Icon(
                    Icons.school_rounded,
                    size: 88,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '愛工大ポータル',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '愛工大アカウントでサインイン',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 40),
                  if (errorMessage.value != null) ...{
                    Text(
                      errorMessage.value!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                  },
                  // メイン導線: EntraID(SSO)ログイン
                  ElevatedButton.icon(
                    onPressed: isLoading.value ? null : login,
                    icon: const Icon(Icons.login),
                    label: const Text('愛工大アカウントでログイン'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  // サブ導線: 事務職員向け(控えめ)
                  TextButton(
                    onPressed: isLoading.value
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (ctx) => const StaffLoginScreen(),
                              ),
                            );
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                    child: const Text(
                      '事務職員の方はこちら',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (isLoading.value) ...{
            const CircularLoadingWidget(),
          },
        ],
      ),
    );
  }
}

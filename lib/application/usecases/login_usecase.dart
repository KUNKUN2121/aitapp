import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/domain/types/identity.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/presentation/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ログイン成功後の共通処理。
///
/// 取得した [identity] を永続化(SharedPreferences)し、状態(identity /
/// lastLogin)を更新したうえで [TabScreen] へ置き換え遷移する。
/// SSO(学生)・ID/パスワード(事務職員)いずれのログイン導線からも呼ばれる。
///
/// [isStaff] はログイン種別。事務職員の 事務ID はメールのローカル部と一致しない
/// ため、Office 365 の login_hint 生成時にこのフラグで学生と出し分ける。
Future<void> completeLogin({
  required BuildContext context,
  required WidgetRef ref,
  required Identity identity,
  bool isStaff = false,
}) async {
  final pref = ref.read(sharedPreferencesProvider);
  await pref.setString('id', identity.id);
  await pref.setString('password', identity.password);
  await pref.setBool('isStaff', isStaff);
  ref.read(identityProvider.notifier).setIdPassword(identity);
  ref.read(lastLoginNotifierProvider.notifier).changeState(LastLogin.others);
  if (!context.mounted) {
    return;
  }
  await Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (ctx) => const TabScreen(),
    ),
  );
}

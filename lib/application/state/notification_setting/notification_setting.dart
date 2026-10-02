import 'package:aitapp/application/services/push_notification.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_setting.g.dart';

/// アプリ内の通知ON/OFF設定を保持する。
///
/// ONで [subscribePushTopic]、OFFで [unsubscribePushTopic] を呼び、学籍番号トピックの
/// 購読を切り替える。設定値は SharedPreferences に保存し、次回起動時も尊重する。
@Riverpod(keepAlive: true)
class NotificationSettingNotifier extends _$NotificationSettingNotifier {
  @override
  bool build() {
    final pref = ref.read(sharedPreferencesProvider);
    return pref.getBool(notificationEnabledKey) ?? true;
  }

  /// 通知ON/OFFを切り替える。[userId] はログイン中の学籍番号(未ログインなら null)。
  Future<void> setEnabled({
    required String? userId,
    required bool enabled,
  }) async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(notificationEnabledKey, enabled);
    state = enabled;
    if (enabled) {
      await subscribePushTopic(userId);
    } else {
      await unsubscribePushTopic(userId);
    }
  }
}

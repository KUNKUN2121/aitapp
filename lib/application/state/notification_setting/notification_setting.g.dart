// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_setting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationSettingNotifierHash() =>
    r'65cef7dfec1a7dabb987df86732471b52743bfb2';

/// アプリ内の通知ON/OFF設定を保持する。
///
/// ONで [subscribePushTopic]、OFFで [unsubscribePushTopic] を呼び、学籍番号トピックの
/// 購読を切り替える。設定値は SharedPreferences に保存し、次回起動時も尊重する。
///
/// Copied from [NotificationSettingNotifier].
@ProviderFor(NotificationSettingNotifier)
final notificationSettingNotifierProvider =
    NotifierProvider<NotificationSettingNotifier, bool>.internal(
  NotificationSettingNotifier.new,
  name: r'notificationSettingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSettingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationSettingNotifier = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

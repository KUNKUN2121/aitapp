// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_login.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lastLoginNotifierHash() => r'71edfdc725bdff086c8a2f9614218d314f96a0fa';

/// お知らせ一覧の再取得トリガ([LastLogin])を保持する。
///
/// これはセッション制御ではなく「最後に表示したお知らせ種別」の記録で、
/// 画面が別種別に変わったときやアプリ復帰時に一覧を取り直すために使う。
/// セッションの確立・再利用・復帰は `LcamSession` が担う。
///
/// Copied from [LastLoginNotifier].
@ProviderFor(LastLoginNotifier)
final lastLoginNotifierProvider =
    NotifierProvider<LastLoginNotifier, LastLogin>.internal(
  LastLoginNotifier.new,
  name: r'lastLoginNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastLoginNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LastLoginNotifier = Notifier<LastLogin>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

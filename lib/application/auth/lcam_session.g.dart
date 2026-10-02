// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcam_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lcamSessionHash() => r'4149b5d228df204309c654008797d831cc655626';

/// アプリ内で唯一のLCAMセッション(JSESSIONID)の所有者。
///
/// LCAMは同一ユーザーで有効なJSESSIONIDが1本しかなく、別々にログインすると
/// 後から確立したセッションが先のものを無効化してしまう。そのため
/// お知らせ・時間割・WebView など全機能はこの [LcamSession] が確立した1本の
/// Cookieを共有する。
///
/// - [ensure] : 有効なセッションがあれば再利用し、無ければ確立する。並行呼び出しは
///   single-flight で1回のログインに束ねる。
/// - [invalidate] : セッションが失効した(サーバが未ログインを返した/仮パスワードを
///   更新した)ときに破棄する。次の [ensure] で確立し直される。
///
/// Copied from [LcamSession].
@ProviderFor(LcamSession)
final lcamSessionProvider = NotifierProvider<LcamSession, Cookies?>.internal(
  LcamSession.new,
  name: r'lcamSessionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$lcamSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LcamSession = Notifier<Cookies?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

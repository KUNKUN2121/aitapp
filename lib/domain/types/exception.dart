class NotFoundException implements Exception {
  const NotFoundException(this.message);
  final String message;
  @override
  String toString() => message;
}

class GetDataException implements Exception {
  const GetDataException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// 時間割取得中にユーザーがキャンセルしたときに投げられる例外。
class TimetableFetchCancelledException implements Exception {
  const TimetableFetchCancelledException();
  @override
  String toString() => '時間割の取得をキャンセルしました';
}

/// サーバが未ログインページを返したときに投げられる、セッション無効の入口シグナル。
///
/// この時点では原因(JSESSIONIDが切れただけ / 仮パスワードが失効した)は区別
/// できない。捕捉した側は `LcamSession.recover()` の復帰階段
/// (再ログイン → SSO再認証 → ログイン画面)で切り分ける。
class SessionExpiredException implements Exception {
  const SessionExpiredException();
  @override
  String toString() => 'ログインの有効期限が切れました';
}

/// 保存済みのid/仮パスワードで再ログインしても未ログインページが返る、
/// = 仮パスワードが失効している状態。学生はSSO再認証で新しい仮パスワードを取得する。
///
/// `LcamSession` 内部のシグナルで、通常は復帰階段の中で消費される。
class CredentialExpiredException implements Exception {
  const CredentialExpiredException();
  @override
  String toString() => '仮パスワードの有効期限が切れました';
}

/// 復帰階段を尽くしても認証できなかった(SSOがキャンセル/失敗、事務職員の
/// パスワード変更、identity未設定など)ときに投げられる。UIはログイン画面へ誘導する。
class AuthenticationRequiredException implements Exception {
  const AuthenticationRequiredException();
  @override
  String toString() => '再度ログインしてください';
}

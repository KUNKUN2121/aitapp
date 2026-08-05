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

/// LCAMのセッション(仮パスワード)が失効し、サーバが未ログインページを返した
/// ときに投げられる例外。
///
/// 学生(SSOログイン)の場合はEntraのCookieが残っているため、これを捕捉して
/// SSO再認証→仮パスワード更新→リトライを自動で行える。
class SessionExpiredException implements Exception {
  const SessionExpiredException();
  @override
  String toString() => 'ログインの有効期限が切れました';
}

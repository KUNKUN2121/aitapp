/// LCAMのセッションCookie。`JSESSIONID` と `LiveApps-Cookie` の**値のみ**を保持する。
///
/// サーバの set-cookie に付く属性(`Path`/`HttpOnly` など)は持たない。
/// リクエストの `Cookie` ヘッダは name=value だけを送れば十分なため、[header] で
/// 組み立てる。
class Cookies {
  const Cookies({
    required this.jsessionid,
    required this.liveApps,
  });

  /// JSESSIONID の値(例: `A1B2C3...`)。
  final String jsessionid;

  /// LiveApps-Cookie の値。
  final String liveApps;

  /// リクエストの `Cookie` ヘッダに載せる文字列。
  String get header => 'JSESSIONID=$jsessionid; LiveApps-Cookie=$liveApps';
}

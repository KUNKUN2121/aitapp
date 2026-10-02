/// お知らせ一覧キャッシュが「最後にどの種別で有効だったか」を表す。
///
/// 名前は歴史的経緯(旧: 画面が変わったら再ログインする判定)で `LastLogin` だが、
/// 現在はセッション制御ではなく **お知らせ一覧の再取得トリガ** として使う。
/// セッションの確立・再利用・復帰は `LcamSession` が担う。
/// - [classNotice] / [univNotice]: その種別の一覧を最後に取得済み(同種別なら再取得不要)
/// - [others]: お知らせ以外の画面を経由した = 次にお知らせを開いたら再取得する
// TODO(auth-rebuild): コミット後に実態に合う名前へリネーム(例: NoticeCacheTab)。
enum LastLogin {
  classNotice,
  univNotice,
  others,
}

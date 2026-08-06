import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/domain/types/notice_detail.dart';
import 'package:aitapp/presentation/screens/webview.dart';
import 'package:aitapp/presentation/wighets/loading/detail_loading.dart';
import 'package:aitapp/presentation/wighets/notice_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 通知の `targetUrl`(学内連絡詳細のパス)から、お知らせ一覧経由と同じ
/// ネイティブ整形詳細([NoticeDetailWidget])を表示する画面。
///
/// ログイン(仮パスワードで再ログイン)→ 認証Cookieで詳細HTMLを取得 → パース。
/// エンドポイント差異等でパースに失敗した場合は、従来どおり生ページを
/// [WebViewScreen] で開いて表示を壊さない。
class NoticeDetailByPathScreen extends HookConsumerWidget {
  const NoticeDetailByPathScreen({
    super.key,
    required this.path,
    required this.isCommon,
  });

  final String path;
  final bool isCommon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<NoticeDetail> load() async {
      await ref.read(getLcamDataNotifierProvider.notifier).create();
      return ref
          .read(getLcamDataNotifierProvider)
          .getNoticeDetailByPath(path: path, isCommon: isCommon);
    }

    final future = useMemoized(load);
    final snapshot = useFuture(future);

    if (snapshot.hasError) {
      // パース不能・通信失敗時は生ページのWebViewにフォールバック。
      return WebViewScreen(url: path, title: 'お知らせ');
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '詳細',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: snapshot.hasData
          ? NoticeDetailWidget(notice: snapshot.data!)
          : const DetailLoadingWidget(),
    );
  }
}

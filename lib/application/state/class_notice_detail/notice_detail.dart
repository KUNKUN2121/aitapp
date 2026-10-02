import 'dart:io';

import 'package:aitapp/application/auth/lcam_session.dart';
import 'package:aitapp/application/state/class_notice/class_notice.dart';
import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/application/state/univ_notice/univ_notice.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:aitapp/domain/types/notice_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notice_detail.g.dart';

@riverpod
class NoticeDetailNotifier extends _$NoticeDetailNotifier {
  @override
  AsyncValue<NoticeDetail> build() {
    return const AsyncValue.loading();
  }

  Future<void> fetchData({
    required int index,
    required int page,
    required bool isCommon,
    required String title,
  }) async {
    final getLcamData = ref.read(getLcamDataNotifierProvider);
    // 詳細取得(goDetail)は一覧フローの現在トークンを使う。一覧を種別ごとに
    // キャッシュしている provider からそのトークンを読む。
    final token = (isCommon
            ? ref.read(univNoticesNotifierProvider)
            : ref.read(classNoticesNotifierProvider))
        ?.token;
    try {
      // 一覧が未取得(token==null)なら最初の試行は飛ばし、下の再取得で一覧ごと取る。
      if (token != null) {
        final result = await getLcamData.getNoticeDetail(
          pageNumber: index,
          isCommon: isCommon,
          token: token,
        );
        state = AsyncValue.data(result);
        return;
      }
    } on SocketException catch (err, stack) {
      state = AsyncValue.error(err, stack);
      return;
    } on Exception catch (err) {
      // セッション無効なら、再取得の前に復帰階段(再ログイン→SSO再認証)を通す。
      if (err is SessionExpiredException) {
        try {
          await ref.read(lcamSessionProvider.notifier).recover();
        } on AuthenticationRequiredException catch (e, stack) {
          state = AsyncValue.error(e, stack);
          return;
        }
      }
      // 下の再取得へフォールスルーする。
    }

    // 一覧を取り直して title で index を再検索し、新しいトークンで詳細を取得する。
    try {
      await ref.read(getLcamDataNotifierProvider.notifier).create();
      final noticelist = await getLcamData.getNoticelist(
        page: page,
        isCommon: isCommon,
        withLogin: true,
      );
      final reSearchIndex = noticelist.notices.indexWhere(
        (element) => element.title == title,
      );
      final result = await getLcamData.getNoticeDetail(
        pageNumber: reSearchIndex,
        isCommon: isCommon,
        token: noticelist.token,
      );
      state = AsyncValue.data(result);
    } on Exception catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}

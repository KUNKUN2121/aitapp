import 'dart:io';
import 'package:aitapp/application/state/class_notice/class_notice.dart';
import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/notice_load/notice_load.dart';
import 'package:aitapp/application/state/univ_notice/univ_notice.dart';
import 'package:aitapp/application/usecases/session_reauth.dart';
import 'package:aitapp/domain/types/class_notice.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/domain/types/notice.dart';
import 'package:aitapp/domain/types/notice_catche.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadNoticeListUseCase {
  LoadNoticeListUseCase({
    required this.ref,
    required this.isCommon,
    required this.context,
    required this.error,
  }) : loginType = isCommon ? LastLogin.univNotice : LastLogin.classNotice {
    getLcamDataNotifier = ref.read(getLcamDataNotifierProvider.notifier);
    lastLoginNotifier = ref.read(lastLoginNotifierProvider.notifier);
    classNoticesNotifier = ref.read(classNoticesNotifierProvider.notifier);
    noticeLoadNotifier = ref.read(noticeLoadNotifierProvider.notifier);
    univNoticesNotifier = ref.read(univNoticesNotifierProvider.notifier);
    if (ref.read(lastLoginNotifierProvider) != loginType) {
      load(withLogin: true);
    }
  }
  late final UnivNoticesNotifier univNoticesNotifier;
  late final NoticeLoadNotifier noticeLoadNotifier;
  late final ClassNoticesNotifier classNoticesNotifier;
  late final LastLoginNotifier lastLoginNotifier;
  late final GetLcamDataNotifier getLcamDataNotifier;
  final WidgetRef ref;
  final bool isCommon;
  final BuildContext context;
  final ValueNotifier<String?> error;
  final LastLogin loginType;
  CancelableOperation<void>? loadOperation;

  List<Notice> filteredList(List<Notice> list, String text) {
    final filter = text;
    if (isCommon) {
      return list
          .where(
            (notice) =>
                notice.title.toLowerCase().contains(
                      filter.toLowerCase(),
                    ) ||
                notice.sender.toLowerCase().contains(
                      filter.toLowerCase(),
                    ),
          )
          .toList();
    }
    return list
        .where(
          (notice) =>
              (notice as ClassNotice).subject.toLowerCase().contains(
                    filter.toLowerCase(),
                  ) ||
              notice.title.toLowerCase().contains(
                    filter.toLowerCase(),
                  ) ||
              notice.sender.toLowerCase().contains(
                    filter.toLowerCase(),
                  ),
        )
        .toList();
  }

  void dispose() {
    loadOperation?.cancel();
  }

  Future<void> load({
    bool withLogin = false,
    bool isRetry = false,
  }) async {
    try {
      error.value = null;
      loadOperation = CancelableOperation.fromFuture(
        _load(withLogin: withLogin),
      );
      await loadOperation!.value;
    } on SocketException {
      if (context.mounted) {
        error.value = 'インターネットに接続できません';
      }
    } on Exception catch (err) {
      // 2回目(リトライ)でも失敗したら、無限ロードせずエラーを表示して終わる。
      if (isRetry) {
        if (context.mounted) {
          error.value = err.toString();
        }
        return;
      }
      // 仮パスワード失効なら、再取得の前にSSO再認証で新パスワードへ更新する。
      // 再認証がキャンセル/失敗したら、盲目的にリトライせずエラーを表示して終わる。
      if (err is SessionExpiredException) {
        final reauthed =
            await ref.read(sessionReauthenticatorProvider).reauthenticate();
        if (!reauthed) {
          if (context.mounted) {
            error.value = 'サインインがキャンセルされました。もう一度お試しください。';
          }
          return;
        }
      }
      // 再認証済み、または一時的なエラー。ログインし直して一度だけ再取得する。
      await load(withLogin: true, isRetry: true);
    }
  }

  Future<void> _load({
    bool withLogin = false,
  }) async {
    final noticeCatche = isCommon
        ? ref.read(univNoticesNotifierProvider)
        : ref.read(classNoticesNotifierProvider);
    final getLcamData = ref.read(getLcamDataNotifierProvider);
    final isloading = ref.read(noticeLoadNotifierProvider);

    if ((noticeCatche != null && noticeCatche.isLast && !withLogin) ||
        (isloading && !withLogin)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      noticeLoadNotifier.changeState(isload: true);
    });

    try {
      if (withLogin) {
        await getLcamDataNotifier.create();

        lastLoginNotifier.changeState(loginType);
      }

      final nextPage = noticeCatche == null ? 10 : noticeCatche.page + 10;
      final result = await getLcamData.getNoticelist(
        page: nextPage,
        isCommon: isCommon,
        withLogin: withLogin,
      );

      final isLast =
          noticeCatche != null && noticeCatche.notices.length == result.length;

      final newCache =
          NoticeCatche(notices: result, page: nextPage, isLast: isLast);
      isCommon
          ? univNoticesNotifier.change(newCache)
          : classNoticesNotifier.change(newCache);
    } finally {
      // 成功・失敗にかかわらずローディングを必ず解除する(無限ロード防止)。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        noticeLoadNotifier.changeState(isload: false);
      });
    }
  }
}

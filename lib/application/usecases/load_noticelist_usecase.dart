import 'dart:io';
import 'package:aitapp/application/state/class_notice/class_notice.dart';
import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/notice_load/notice_load.dart';
import 'package:aitapp/application/state/univ_notice/univ_notice.dart';
import 'package:aitapp/domain/types/class_notice.dart';
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
  });
  final WidgetRef ref;
  final bool isCommon;
  final BuildContext context;
  final ValueNotifier<String?> error;
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

  void cancel() {
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
      if (!isRetry) {
        await load(
          withLogin: true,
          isRetry: true,
        );
      } else if (context.mounted) {
        error.value = err.toString();
      }
    }
  }

  Future<void> _load({
    bool withLogin = false,
  }) async {
    final loginType = isCommon ? LastLogin.univNotice : LastLogin.classNotice;
    final getLcamDataNotifier = ref.read(getLcamDataNotifierProvider.notifier);
    final lastLoginNotifier = ref.read(lastLoginNotifierProvider.notifier);
    final classNoticesNotifier =
        ref.read(classNoticesNotifierProvider.notifier);
    final getLcamData = ref.read(getLcamDataNotifierProvider);
    final noticeLoadNotifier = ref.read(noticeLoadNotifierProvider.notifier);
    final isLoading = ref.read(noticeLoadNotifierProvider);
    final univNoticesNotifier = ref.read(univNoticesNotifierProvider.notifier);
    final noticeCatche = isCommon
        ? ref.read(univNoticesNotifierProvider)
        : ref.read(classNoticesNotifierProvider);

    if ((noticeCatche != null && noticeCatche.isLast && !withLogin) ||
        (isLoading && !withLogin)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      noticeLoadNotifier.changeState(isload: true);
    });

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newCache =
          NoticeCatche(notices: result, page: nextPage, isLast: isLast);
      isCommon
          ? univNoticesNotifier.change(newCache)
          : classNoticesNotifier.change(newCache);
      noticeLoadNotifier.changeState(isload: false);
    });
  }
}

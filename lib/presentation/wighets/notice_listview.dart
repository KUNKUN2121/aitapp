import 'dart:io';

import 'package:aitapp/application/state/class_notices_provider.dart';
import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/tab_button_provider.dart';
import 'package:aitapp/application/state/univ_notices_provider.dart';
import 'package:aitapp/domain/types/class_notice.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/domain/types/notice.dart';
import 'package:aitapp/domain/types/univ_notice.dart';
import 'package:aitapp/presentation/wighets/notice_item.dart';
import 'package:aitapp/presentation/wighets/search_bar.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NoticeList extends HookConsumerWidget {
  const NoticeList({
    super.key,
    required this.loading,
    required this.tabs,
    required this.isCommon,
  });

  final void Function({required bool state}) loading;
  final ValueNotifier<int> tabs;
  final bool isCommon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginType = useMemoized(
      () => isCommon ? LastLogin.univNotice : LastLogin.classNotice,
    );
    final getLcamData =
        useMemoized(() => ref.read(getLcamDataNotifierProvider));
    final content = useState<Widget>(
      const Center(
        child: SizedBox(
          height: 25, //指定
          width: 25, //指定
          child: CircularProgressIndicator(),
        ),
      ),
    );
    final pageKey = useMemoized(
      () => ValueKey(
        isCommon ? 'univNoticePage' : 'classNoticePage',
      ),
    );
    final scrollKey = useMemoized(
      () => ValueKey(
        isCommon ? 'univScrollOffset' : 'classScrollOffset',
      ),
    );
    final error = useState<String?>(null);
    final isLoading = useState(false);
    final filter = useState('');
    final beforeReloadLengh = useRef(0);
    final page = useRef(
      (PageStorage.of(context).readState(
            context,
            identifier: pageKey,
          ) ??
          10) as int,
    );
    final isManual = useRef(false);
    final operation = useRef<CancelableOperation<void>?>(null);
    final textEditingController = useTextEditingController();
    final isDispose = useRef(false);
    final controller = useScrollController(
      initialScrollOffset:
          (PageStorage.of(context).readState(context, identifier: scrollKey) ??
              0.0) as double,
    );

    List<Notice> filteredList(List<Notice> list) {
      late final List<Notice> result;
      if (isCommon) {
        result = list
            .where(
              (notice) =>
                  notice.title.toLowerCase().contains(
                        filter.value.toLowerCase(),
                      ) ||
                  notice.sender.toLowerCase().contains(
                        filter.value.toLowerCase(),
                      ),
            )
            .toList();
      } else {
        result = list
            .where(
              (notice) =>
                  (notice as ClassNotice).subject.toLowerCase().contains(
                        filter.value.toLowerCase(),
                      ) ||
                  notice.title.toLowerCase().contains(
                        filter.value.toLowerCase(),
                      ) ||
                  notice.sender.toLowerCase().contains(
                        filter.value.toLowerCase(),
                      ),
            )
            .toList();
      }

      return result;
    }

    Future<void> load({
      required bool withLogin,
      bool isRetry = false,
    }) async {
      late final List<Notice> result;
      error.value = null;
      loading(state: true);
      isLoading.value = true;
      try {
        if (withLogin) {
          await ref.read(getLcamDataNotifierProvider.notifier).create();
          ref.read(lastLoginNotifierProvider.notifier).changeState(loginType);
        }
        result = await getLcamData.getNoticelist(
          page: page.value,
          isCommon: isCommon,
          withLogin: withLogin,
        );
        if (!isDispose.value) {
          if (isCommon) {
            ref
                .read(univNoticesProvider.notifier)
                .reloadNotices(result as List<UnivNotice>);
          } else {
            ref
                .read(classNoticesProvider.notifier)
                .reloadNotices(result as List<ClassNotice>);
          }
        }
      } on SocketException {
        if (!isDispose.value) {
          error.value = 'インターネットに接続できません';
        }
      } on Exception catch (err) {
        if (!isRetry) {
          await load(withLogin: true, isRetry: true);
        } else if (!isDispose.value) {
          error.value = err.toString();
        }
      }
      if (!isDispose.value) {
        loading(state: false);
        isLoading.value = false;
      }
    }

    ref
      ..listen(lastLoginNotifierProvider, (previous, next) {
        if (next != loginType) {
          operation.value = CancelableOperation.fromFuture(
            load(withLogin: true),
          );
        }
      })
      ..listen(tabButtonProvider, (previous, next) {
        controller.animateTo(
          0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
        );
      });

    useEffect(
      () {
        final lastNoticeLoginProvider = ref.read(lastLoginNotifierProvider);
        if (lastNoticeLoginProvider == LastLogin.others ||
            lastNoticeLoginProvider != loginType) {
          operation.value = CancelableOperation.fromFuture(
            load(withLogin: true),
          );
        }
        textEditingController.addListener(() {
          filter.value = textEditingController.text;
        });
        return () {
          if (operation.value != null) {
            operation.value!.cancel();
          }
          isDispose.value = true;
        };
      },
      [],
    );

    if ((isCommon && ref.read(univNoticesProvider) != null) ||
        (!isCommon && ref.read(classNoticesProvider) != null)) {
      if (error.value == null) {
        final result = isCommon
            ? ref.read(univNoticesProvider)!
            : ref.read(classNoticesProvider)!;
        final filteredResult = filteredList(result);
        content.value = NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification) {
              PageStorage.of(context).writeState(
                context,
                controller.offset,
                identifier: scrollKey,
              );
            }
            return true;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              isManual.value = true;
              if (!isLoading.value) {
                page.value = 10;
                beforeReloadLengh.value = 0;
                await load(withLogin: true);
              }
              if (!isDispose.value) {
                isManual.value = false;
              }
            },
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverAppBar(
                  scrolledUnderElevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  automaticallyImplyLeading: false,
                  expandedHeight: 80,
                  snap: true,
                  floating: true,
                  flexibleSpace: SearchBarWidget(
                    controller: textEditingController,
                    hintText: '送信元、キーワードで検索',
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext c, int i) {
                      if (i == filteredResult.length - 3) {
                        if (!isLoading.value &&
                            filteredResult.length != beforeReloadLengh.value) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            page.value += 10;
                            beforeReloadLengh.value = filteredResult.length;
                            PageStorage.of(context).writeState(
                              context,
                              page.value,
                              identifier: pageKey,
                            );
                            load(withLogin: false);
                          });
                        }
                      }
                      return NoticeItem(
                        notice: filteredResult[i],
                        index: result.indexOf(filteredResult[i]),
                        getLcamData: getLcamData,
                        tap: !isLoading.value,
                        isCommon: isCommon,
                        page: page.value,
                      );
                    },
                    childCount: filteredResult.length,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: error.toString());
      }
    } else if (error.value != null) {
      content.value = Center(
        child: Text(error.value!),
      );
    }
    return Column(
      children: [
        LinearProgressIndicator(
          minHeight: 2,
          value: isLoading.value &&
                  ((isCommon && ref.read(univNoticesProvider) != null) ||
                      (!isCommon && ref.read(classNoticesProvider) != null)) &&
                  !isManual.value
              ? null
              : 0,
        ),
        Expanded(
          child: content.value,
        ),
      ],
    );
  }
}

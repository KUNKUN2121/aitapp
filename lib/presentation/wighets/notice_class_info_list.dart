import 'package:aitapp/application/state/notice_load/notice_load.dart';
import 'package:aitapp/application/state/tab_button_provider.dart';
import 'package:aitapp/domain/types/notice.dart';
import 'package:aitapp/presentation/wighets/notice_class_info_item.dart';
import 'package:aitapp/presentation/wighets/notice_item.dart';
import 'package:aitapp/presentation/wighets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NoticeClassInfoListWidget extends HookConsumerWidget {
  const NoticeClassInfoListWidget({
    super.key,
    required this.notices,
    required this.page,
    required this.onLast,
    required this.onRefresh,
    required this.isCommon,
    required this.textController,
  });
  final int page;
  final List<Notice> notices;
  final void Function()? onLast;
  final Future<void> Function() onRefresh;
  final bool isCommon;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollKey = useMemoized(
      () => ValueKey(
        isCommon ? 'univScrollOffset' : 'classScrollOffset',
      ),
    );
    final controller = useMemoized(
      () => ScrollController(
        initialScrollOffset: (PageStorage.of(context)
                .readState(context, identifier: scrollKey) ??
            0.0) as double,
      ),
    );
    ref.listen(tabButtonProvider, (previous, next) {
      controller.animateTo(
        0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });

    return Column(
      children: [
        LinearProgressIndicator(
          minHeight: 2,
          value: ref.watch(noticeLoadNotifierProvider) ? null : 0,
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
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
              onRefresh: onRefresh,
              child: ListView.builder(
                controller: controller,
                itemCount: notices.length,
                itemBuilder: (BuildContext c, int i) {
                  if (i == notices.length - 3) {
                    if (onLast != null &&
                        !ref.read(noticeLoadNotifierProvider)) {
                      onLast!();
                    }
                  }
                  return NoticeClassInfoItem(
                    notice: notices[i],
                    isCommon: isCommon,
                    page: page,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

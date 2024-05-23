import 'package:aitapp/application/state/class_notice/class_notice.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/univ_notice/univ_notice.dart';
import 'package:aitapp/application/usecases/load_noticelist_usecase.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/presentation/wighets/notice_item.dart';
import 'package:aitapp/presentation/wighets/notice_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NoticeTabPage extends HookConsumerWidget {
  const NoticeTabPage({super.key, required this.isCommon});
  final bool isCommon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final usecase = LoadNoticeListUseCase(
      isCommon: isCommon,
      ref: ref,
    );
    final noticeCatche = isCommon
        ? ref.watch(univNoticesNotifierProvider)
        : ref.watch(classNoticesNotifierProvider);

    ref.listen(lastLoginNotifierProvider, (previous, next) {
      if (next == LastLogin.others) {
        usecase.load(withLogin: true);
      }
    });

    useEffect(
      () {
        controller.addListener(() {
          controller.text;
        });
        if (ref.read(lastLoginNotifierProvider) !=
            (isCommon ? LastLogin.univNotice : LastLogin.classNotice)) {
          usecase.load(withLogin: true);
        }
        return usecase.cancel;
      },
      [],
    );

    return noticeCatche != null
        ? NoticeListWidget(
            textController: controller,
            isCommon: isCommon,
            notices: List<NoticeItem>.generate(
              noticeCatche.notices.length,
              (i) => NoticeItem(
                notice: noticeCatche.notices[i],
                index: i,
                isCommon: isCommon,
                page: noticeCatche.page,
              ),
            ),
            onRefresh: () async {
              await usecase.load(withLogin: true);
            },
            onLast: usecase.load,
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

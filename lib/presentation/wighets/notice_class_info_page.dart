import 'package:aitapp/application/state/class_notice/class_notice.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/univ_notice/univ_notice.dart';
import 'package:aitapp/application/usecases/load_noticelist_usecase.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/presentation/wighets/loading.dart';
import 'package:aitapp/presentation/wighets/notice_class_info_list.dart';
import 'package:aitapp/presentation/wighets/notice_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NoticeClassInfoPage extends HookConsumerWidget {
  const NoticeClassInfoPage(
      {super.key, required this.isCommon, required this.clas});
  final bool isCommon;
  final Class clas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = useState<String?>(null);
    final result = useState('');
    final usecase = useMemoized(
      () => LoadNoticeListUseCase(
        error: error,
        context: context,
        isCommon: isCommon,
        ref: ref,
      ),
    );
    final controller = useTextEditingController();
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
          result.value = controller.text;
        });
        return usecase.dispose;
      },
      [],
    );

    result.value = clas.title;

    if (error.value == null) {
      if (noticeCatche != null) {
        return NoticeClassInfoListWidget(
          textController: controller,
          isCommon: isCommon,
          notices: usecase.filteredList(noticeCatche.notices, result.value),
          page: noticeCatche.page,
          onRefresh: () async {
            await usecase.load(withLogin: true);
          },
          onLast: usecase.load,
        );
      }
      return const LoadingWidget();
    }
    return Center(
      child: Text(error.value!),
    );
  }
}

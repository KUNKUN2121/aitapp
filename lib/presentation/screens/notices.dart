import 'package:aitapp/application/state/notice_load/notice_load.dart';
import 'package:aitapp/presentation/wighets/notice_tab_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NoticeScreen extends HookConsumerWidget with RouteAware {
  const NoticeScreen({
    super.key,
  });

  static const pageLength = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = useState<int>(
      (PageStorage.of(context).readState(
            context,
            identifier: const ValueKey('currentPage'),
          ) ??
          0) as int,
    );
    final tabController = useTabController(
      initialLength: pageLength,
      initialIndex: currentPage.value,
    );
    final isLoading = ref.watch(noticeLoadNotifierProvider);

    useEffect(
      () {
        tabController.animateTo(
          currentPage.value,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 250),
        );
        PageStorage.of(context).writeState(
          context,
          currentPage.value,
          identifier: const ValueKey('currentPage'),
        );
        return null;
      },
      [currentPage.value],
    );

    return Column(
      children: [
        IgnorePointer(
          ignoring: isLoading,
          child: TabBar(
            tabs: const [
              Tab(text: '学内'),
              Tab(text: '授業'),
            ],
            controller: tabController,
            onTap: (index) {
              if (!isLoading) {
                currentPage.value = index;
              }
            },
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0 &&
                  !isLoading &&
                  0 < currentPage.value) {
                //左ページへ
                currentPage.value -= 1;
              } else if (details.primaryVelocity! < 0 &&
                  !isLoading &&
                  pageLength - 1 > currentPage.value) {
                //右ページへ
                currentPage.value += 1;
              }
            },
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: const [
                NoticeTabPage(
                  isCommon: true,
                ),
                NoticeTabPage(
                  isCommon: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

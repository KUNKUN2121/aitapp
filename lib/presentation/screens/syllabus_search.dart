import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/application/state/syllabus_filter/syllabus_filters.dart';
import 'package:aitapp/application/state/syllabus_search/syllabus_search.dart';
import 'package:aitapp/application/usecases/syllabus_search_usecase.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/class_syllabus.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/presentation/screens/syllabus_detail.dart';
import 'package:aitapp/presentation/wighets/filter_drawer.dart';
import 'package:aitapp/presentation/wighets/loading/notice_loading.dart';
import 'package:aitapp/presentation/wighets/search_bar.dart';
import 'package:aitapp/presentation/wighets/syllabus_filter_chips.dart';
import 'package:aitapp/presentation/wighets/syllabus_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SyllabusSearchScreen extends HookConsumerWidget {
  SyllabusSearchScreen({
    super.key,
    this.initialWord,
    this.initialWeek,
    this.initialHour,
    this.initialYear,
  });

  /// 時間割などから開いたときの初期検索ワード(授業コード等)。
  final String? initialWord;

  /// 初期の曜日フィルタ。
  final DayOfWeek? initialWeek;

  /// 初期の時限フィルタ。
  final int? initialHour;

  /// 初期の年度(時間割で選択中の年度など)。
  final int? initialYear;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final getSyllabus = useMemoized(GetSyllabus.new);
    final focusNode = useMemoized(FocusNode.new);
    final useCase = useMemoized(
      () => SyllabusSearchUseCase(
        getSyllabus: getSyllabus,
        controller: controller,
        ref: ref,
        presetWord: initialWord,
        presetWeek: initialWeek,
        presetHour: initialHour,
        presetYear: initialYear,
      ),
    );
    final content = ref.watch(syllabusSearchNotifierProvider);

    // 時間割などからプリセットで開かれたか。プリセット時は結果が確定するまで
    // 検索UIを見せずにローディングのみ表示する(検索画面の一瞬の点滅を防ぐ)。
    final hasPreset =
        initialWord != null || initialWeek != null || initialHour != null;
    final showSearchUi = useState(!hasPreset);

    // 検索結果がちょうど1件のときは詳細画面へ自動遷移する。
    // ref.listen は状態変化時のみ発火するため、詳細から戻っても再遷移しない。
    ref.listen<AsyncValue<List<ClassSyllabus>>>(
      syllabusSearchNotifierProvider,
      (previous, next) {
        // ローディング中は判定しない(確定まで待つ)。
        if (next.isLoading) {
          return;
        }
        final list = next.valueOrNull;
        if (list != null && list.length == 1) {
          // プリセット由来の初回1件は検索画面を挟まず詳細へ置き換え遷移する。
          // (詳細から戻ると時間割など元の画面に直接戻る)
          final replace = !showSearchUi.value;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              return;
            }
            final route = MaterialPageRoute<void>(
              builder: (ctx) => SyllabusDetail(
                syllabus: list.first,
                getSyllabus: getSyllabus,
              ),
            );
            if (replace) {
              Navigator.of(context).pushReplacement(route);
            } else {
              Navigator.of(context).push(route);
            }
          });
        } else {
          // 0件/複数/エラー時は検索UIを表示して手動で絞り込ませる。
          showSearchUi.value = true;
        }
      },
    );

    useEffect(
      () {
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            controller.text =
                ref.read(selectSyllabusFilterNotifierProvider)?.word ?? '';
          }
        });
        return focusNode.dispose;
      },
      [],
    );

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: FilterDrawer(
        setFilters: useCase.setFilters,
        getSyllabus: getSyllabus,
      ),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'シラバス検索',
        ),
        actions: const [SizedBox()],
      ),
      body: !showSearchUi.value
          // プリセットの結果が確定するまではローディングのみ表示する。
          ? const NoticeLoadingWidget(isCommon: true)
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SearchBarWidget(
                        onSuffixIconPusshed: useCase.onClear,
                        onSubmitted: useCase.onSubmit,
                        focusNode: focusNode,
                        controller: controller,
                        hintText: '教授名、授業名で検索',
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (ref.read(syllabusFiltersNotifierProvider) != null) {
                          _scaffoldKey.currentState?.openEndDrawer();
                        }
                      },
                      icon: const Icon(Icons.filter_alt),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilledButton(
                        // キーワード無しでもフィルタだけで検索を実行できる。
                        onPressed: () {
                          focusNode.unfocus();
                          useCase.onSubmit(controller.text);
                        },
                        child: const Text('検索'),
                      ),
                    ),
                  ],
                ),
                SyllabusFilterChips(
                  setFilters: useCase.setFilters,
                ),
                content.when(
                  error: (error, stackTrace) {
                    return Center(
                      child: Text(error.toString()),
                    );
                  },
                  loading: () => const Expanded(
                    child: NoticeLoadingWidget(
                      isCommon: true,
                    ),
                  ),
                  data: (data) {
                    if (data.isEmpty) {
                      return const SizedBox.shrink();
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (c, i) => SyllabusItem(
                            syllabus: data[i],
                            getSyllabus: getSyllabus,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
    );
  }
}

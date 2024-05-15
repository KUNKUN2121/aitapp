import 'dart:io';

import 'package:aitapp/application/state/filter_provider.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/select_filter.dart';
import 'package:aitapp/presentation/wighets/filter_drawer.dart';
import 'package:aitapp/presentation/wighets/search_bar.dart';
import 'package:aitapp/presentation/wighets/syllabus_search_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SyllabusSearchScreen extends HookConsumerWidget {
  SyllabusSearchScreen({
    super.key,
  });
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final syllabusList = useState<Widget>(const SizedBox());
    final typeWord = useState('');
    final getSyllabus = useMemoized(GetSyllabus.new);

    void onSubmit(
      //検索処理
      String word,
    ) {
      syllabusList.value = SyllabusSearchList(
        searchtext: typeWord.value,
      );
    }

    void setFilters({
      required SelectFilters selectFilters,
    }) {
      //フィルターが変化
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectFiltersProvider.notifier).state = selectFilters;
        onSubmit(typeWord.value);
      });
    }

    Future<void> getFilters() async {
      //フィルター取得
      try {
        await getSyllabus.create();
        if (ref.read(syllabusFiltersProvider) == null) {
          ref.read(syllabusFiltersProvider.notifier).state =
              getSyllabus.filters;
          ref.read(selectFiltersProvider.notifier).state = SelectFilters(
            year: getSyllabus.filters.year.values.first,
          );
        }
      } on SocketException {
        await Fluttertoast.showToast(msg: 'インターネットに接続できません');
      } on Exception catch (err) {
        await Fluttertoast.showToast(msg: err.toString());
      }
    }

    useEffect(
      () {
        controller.addListener(() {
          typeWord.value = controller.text;
        });
        getFilters();
        return null;
      },
      [],
    );

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: FilterDrawer(
        setFilters: setFilters,
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
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SearchBarWidget(
                  onSubmitted: onSubmit,
                  controller: controller,
                  hintText: '教授名、授業名で検索',
                ),
              ),
              IconButton(
                onPressed: () {
                  if (ref.read(syllabusFiltersProvider) != null) {
                    _scaffoldKey.currentState?.openEndDrawer();
                  }
                },
                icon: const Icon(Icons.filter_alt),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
          syllabusList.value,
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/application/state/syllabus_filter/syllabus_filters.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/select_syllabus_filters.dart';
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
    final getSyllabus = useMemoized(GetSyllabus.new);
    final focusNode = useMemoized(FocusNode.new);

    void onSubmit(
      // エンターが押されたときに実行される 検索処理
      String word,
    ) {
      ref
          .read(selectSyllabusFilterNotifierProvider.notifier)
          .changeWord(word: word);
    }

    void onClear() {
      // 検索ワード削除
      controller.text = '';
      ref
          .read(selectSyllabusFilterNotifierProvider.notifier)
          .changeWord(word: '');
    }

    Future<void> getFilters() async {
      //フィルター取得
      try {
        await getSyllabus.create();
        await ref
            .read(syllabusFiltersNotifierProvider.notifier)
            .create(getSyllabus);
      } on SocketException {
        await Fluttertoast.showToast(msg: 'インターネットに接続できません');
      } on Exception catch (err) {
        await Fluttertoast.showToast(msg: err.toString());
      }
    }

    void setFilters({
      required SelectSyllabusFilters selectFilters,
    }) {
      //フィルターが変化
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(selectSyllabusFilterNotifierProvider.notifier)
            .change(filter: selectFilters);
      });
    }

    useEffect(
      () {
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            controller.text =
                ref.watch(selectSyllabusFilterNotifierProvider)?.word ?? '';
          }
        });

        getFilters();
        return focusNode.dispose;
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
                  onSuffixIconPusshed: onClear,
                  onSubmitted: onSubmit,
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
              const SizedBox(
                width: 5,
              ),
            ],
          ),
          SyllabusSearchList(getSyllabus: getSyllabus),
        ],
      ),
    );
  }
}

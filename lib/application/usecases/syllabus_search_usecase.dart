import 'dart:io';

import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/application/state/syllabus_filter/syllabus_filters.dart';
import 'package:aitapp/application/state/syllabus_search/syllabus_search.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/class_syllabus.dart';
import 'package:aitapp/domain/types/select_syllabus_filters.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SyllabusSearchUseCase {
  SyllabusSearchUseCase({
    required this.getSyllabus,
    required this.controller,
    required this.ref,
  }) {
    getFilters();
  }
  final GetSyllabus getSyllabus;
  final TextEditingController controller;
  final WidgetRef ref;
  CancelableOperation<List<ClassSyllabus>>? loadOperation;

  void refresh() {
    final filter = ref.read(selectSyllabusFilterNotifierProvider);
    if (filter != null && !filter.isNull()) {
      ref.read(syllabusSearchNotifierProvider.notifier).fetchData(this);
    } else {
      ref.read(syllabusSearchNotifierProvider.notifier).clear();
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
      refresh();
    });
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

  void onSubmit(
    // エンターが押されたときに実行される 検索処理
    String word,
  ) {
    ref
        .read(selectSyllabusFilterNotifierProvider.notifier)
        .changeWord(word: word);
    refresh();
  }

  void onClear() {
    // 検索ワード削除
    controller.text = '';
    ref
        .read(selectSyllabusFilterNotifierProvider.notifier)
        .changeWord(word: '');
    refresh();
  }

  Future<List<ClassSyllabus>> load(
    SelectSyllabusFilters selectFilter,
  ) async {
    loadOperation = CancelableOperation.fromFuture(
      _load(selectFilter),
    );
    return loadOperation!.value;
  }

  Future<List<ClassSyllabus>> _load(
    SelectSyllabusFilters selectFilter,
  ) async {
    return getSyllabus.getSyllabusList(
      selectSyllabusFilters: selectFilter,
    );
  }

  void dispose() {
    loadOperation?.cancel();
  }
}

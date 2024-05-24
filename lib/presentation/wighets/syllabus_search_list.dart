import 'dart:io';

import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/select_syllabus_filters.dart';
import 'package:aitapp/presentation/wighets/syllabus_item.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SyllabusSearchList extends HookConsumerWidget {
  const SyllabusSearchList({
    super.key,
    required this.getSyllabus,
  });
  final GetSyllabus getSyllabus;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operation = useRef<CancelableOperation<void>?>(null);
    final content = useState<Widget>(const SizedBox());

    Future<void> load(SelectSyllabusFilters selectFilter) async {
      content.value = const Expanded(
        child: Center(
          child: SizedBox(
            height: 25, //指定
            width: 25, //指定
            child: CircularProgressIndicator(),
          ),
        ),
      );
      try {
        final list = await getSyllabus.getSyllabusList(
          selectSyllabusFilters: selectFilter,
        );
        content.value = Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (c, i) => SyllabusItem(
              syllabus: list[i],
              getSyllabus: getSyllabus,
            ),
          ),
        );
      } on SocketException {
        content.value = const Center(
          child: Text('インターネットに接続できません'),
        );
      } on Exception catch (err) {
        content.value = Center(
          child: Text(err.toString()),
        );
      }
    }

    ref.listen(selectSyllabusFilterNotifierProvider, (previous, next) {
      if (next != null && !next.isNull()) {
        operation.value = CancelableOperation.fromFuture(load(next));
      } else {
        content.value = const SizedBox();
      }
    });

    useEffect(
      () {
        return () {
          operation.value?.cancel();
        };
      },
      [],
    );

    return content.value;
  }
}

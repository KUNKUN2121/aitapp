import 'dart:io';

import 'package:aitapp/application/state/filter_provider.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/presentation/wighets/syllabus_item.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SyllabusSearchList extends HookConsumerWidget {
  const SyllabusSearchList({
    super.key,
    this.searchtext,
  });
  final String? searchtext;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getSyllabus = useMemoized(GetSyllabus.new);
    final operation = useRef<CancelableOperation<void>?>(null);
    final content = useState<Widget>(const SizedBox());

    Future<void> load() async {
      final selectFilter = ref.read(selectFiltersProvider);
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
        await getSyllabus.create();
        final list = await getSyllabus.getSyllabusList(
          dayOfWeek: selectFilter!.week,
          searchWord: searchtext,
          classPeriod: selectFilter.hour,
          campus: selectFilter.campus,
          semester: selectFilter.semester,
          folder: selectFilter.folder,
          year: selectFilter.year,
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

    ref.listen(selectFiltersProvider, (previous, next) {
      if (next != null) {
        operation.value = CancelableOperation.fromFuture(load());
      }
    });

    useEffect(
      () {
        return () {
          operation.value!.cancel();
        };
      },
      [],
    );
    useEffect(
      () {
        operation.value = CancelableOperation.fromFuture(load());
        return () {};
      },
      [searchtext],
    );

    return content.value;
  }
}

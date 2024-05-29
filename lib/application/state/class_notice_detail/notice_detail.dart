import 'dart:io';

import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/domain/types/notice_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notice_detail.g.dart';

@riverpod
class NoticeDetailNotifier extends _$NoticeDetailNotifier {
  @override
  AsyncValue<NoticeDetail> build() {
    return const AsyncValue.loading();
  }

  Future<void> fetchData({
    required int index,
    required int page,
    required bool isCommon,
    required String title,
  }) async {
    final getLcamData = ref.read(getLcamDataNotifierProvider);
    try {
      final result = await getLcamData.getNoticeDetail(
        pageNumber: index,
        isCommon: isCommon,
      );
      state = AsyncValue.data(result);
    } on SocketException catch (err, stack) {
      state = AsyncValue.error(err, stack);
    } on Exception {
      try {
        await ref.read(getLcamDataNotifierProvider.notifier).create();
        final noticelist = await getLcamData.getNoticelist(
          page: page,
          isCommon: isCommon,
          withLogin: true,
        );
        final reSearchIndex = noticelist.indexWhere(
          (element) => element.title == title,
        );
        final result = await getLcamData.getNoticeDetail(
          pageNumber: reSearchIndex,
          isCommon: isCommon,
        );
        state = AsyncValue.data(result);
      } on Exception catch (err, stack) {
        state = AsyncValue.error(err, stack);
      }
    }
  }
}

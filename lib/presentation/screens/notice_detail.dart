import 'dart:io';

import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/domain/types/notice_detail.dart';
import 'package:aitapp/presentation/screens/open_file_pdf.dart';
import 'package:aitapp/presentation/screens/open_image.dart';
import 'package:aitapp/presentation/wighets/attachment.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeDetailScreen extends HookConsumerWidget {
  const NoticeDetailScreen({
    super.key,
    required this.index,
    required this.isCommon,
    required this.title,
    required this.page,
  });

  final int index;
  final bool isCommon;
  final String title;
  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getLcamData =
        useMemoized(() => ref.read(getLcamDataNotifierProvider));
    final error = useState<String?>(null);
    final notice = useState<NoticeDetail?>(null);
    final operation = useRef<CancelableOperation<void>?>(null);
    final isDonwloading = useState(false);
    final content = useState<Widget>(
      const Center(
        child: SizedBox(
          height: 25, //指定
          width: 25, //指定
          child: CircularProgressIndicator(),
        ),
      ),
    );

    Future<void> loadData() async {
      try {
        notice.value = await getLcamData.getNoticeDetail(
          pageNumber: index,
          isCommon: isCommon,
        );
      } on SocketException {
        error.value = 'インターネットに接続できません';
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
          notice.value = await getLcamData.getNoticeDetail(
            pageNumber: reSearchIndex,
            isCommon: isCommon,
          );
        } on Exception catch (err) {
          error.value = err.toString();
        }
      }
    }

    useEffect(
      () {
        operation.value = CancelableOperation.fromFuture(
          loadData(),
        );

        return () {
          operation.value!.cancel();
        };
      },
      [],
    );
    if (notice.value != null) {
      content.value = ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(notice.value!.sendAt),
              Text(notice.value!.sender),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          SelectionArea(
            child: Column(
              children: [
                Text(
                  notice.value!.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                HtmlWidget(
                  notice.value!.content,
                  customStylesBuilder: (element) => element.localName == 'a'
                      ? {
                          'color':
                              Theme.of(context).colorScheme.primary.toString(),
                          'text-decoration': 'none',
                          'font-weight': '500',
                        }
                      : null,
                  onTapUrl: (url) => launchUrl(Uri.parse(url)),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (notice.value!.url.isNotEmpty) ...{
                  for (final url in notice.value!.url) ...{
                    Attachment(
                      isUrl: true,
                      attachName: url.replaceAll(RegExp('https?://'), ''),
                      onTap: () {
                        launchUrl(Uri.parse(url));
                      },
                    ),
                  },
                },
                if (notice.value!.files.isNotEmpty) ...{
                  for (final entries in notice.value!.files.entries) ...{
                    Attachment(
                      isUrl: false,
                      attachName: entries.key,
                      onTap: isDonwloading.value
                          ? null
                          : () async {
                              isDonwloading.value = true;
                              try {
                                final file = await getLcamData.shareFile(
                                  entries,
                                  context,
                                );
                                if (file.path.contains('.pdf')) {
                                  if (context.mounted) {
                                    await Navigator.of(context).push<void>(
                                      MaterialPageRoute(
                                        builder: (BuildContext ctx) =>
                                            OpenFilePdf(
                                          title: basename(file.path),
                                          file: file,
                                        ),
                                      ),
                                    );
                                  }
                                  await file.delete();
                                } else if (file.path
                                    .contains(RegExp(r'\.(jpg|png|jpeg)$'))) {
                                  if (context.mounted) {
                                    await Navigator.of(context).push<void>(
                                      MaterialPageRoute(
                                        builder: (BuildContext ctx) =>
                                            OpenFileImage(
                                          title: basename(file.path),
                                          file: file,
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  final xfile = [XFile(file.path)];
                                  await Share.shareXFiles(xfile);
                                }
                              } on SocketException {
                                await Fluttertoast.showToast(
                                  msg: 'インターネットに接続できません',
                                );
                              } on Exception catch (err) {
                                await Fluttertoast.showToast(
                                  msg: err.toString(),
                                );
                              }
                              isDonwloading.value = false;
                            },
                    ),
                  },
                },
              ],
            ),
          ),
        ],
      );
    }
    if (error.value != null) {
      content.value = Center(
        child: Text(error.value!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '詳細',
        ),
      ),
      body: content.value,
    );
  }
}

import 'dart:io';

import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/domain/types/notice_detail.dart';
import 'package:aitapp/presentation/screens/open_file_pdf.dart';
import 'package:aitapp/presentation/screens/open_image.dart';
import 'package:aitapp/presentation/wighets/attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeDetailWidget extends HookConsumerWidget {
  const NoticeDetailWidget({
    super.key,
    required this.notice,
  });
  final NoticeDetail notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDonwloading = useState(false);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(notice.sendAt),
            Text(notice.sender),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        SelectionArea(
          child: Column(
            children: [
              Text(
                notice.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              HtmlWidget(
                notice.content,
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
              if (notice.url.isNotEmpty) ...{
                for (final url in notice.url) ...{
                  Attachment(
                    isUrl: true,
                    attachName: url.replaceAll(RegExp('https?://'), ''),
                    onTap: () {
                      launchUrl(Uri.parse(url));
                    },
                  ),
                },
              },
              if (notice.files.isNotEmpty) ...{
                for (final entries in notice.files.entries) ...{
                  Attachment(
                    isUrl: false,
                    attachName: entries.key,
                    onTap: isDonwloading.value
                        ? null
                        : () async {
                            isDonwloading.value = true;
                            try {
                              final file = await ref
                                  .read(getLcamDataNotifierProvider)
                                  .shareFile(
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
                              } else if (file.path.contains(
                                RegExp(r'\.(jpg|png|jpeg)$'),
                              )) {
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
}

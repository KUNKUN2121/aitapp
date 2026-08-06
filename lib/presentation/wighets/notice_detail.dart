import 'dart:io';

import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/domain/types/notice_detail.dart';
import 'package:aitapp/domain/types/univ_notice_detail.dart';
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
    final univ = notice is UnivNoticeDetail ? notice as UnivNoticeDetail : null;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      children: [
        Card(
          elevation: 0,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          univ != null && univ.noticeFrom.isNotEmpty
                              ? univ.noticeFrom
                              : notice.sender,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notice.sendAt,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                if (univ != null && univ.sender.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.apartment_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        univ.sender,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (univ != null &&
                  (univ.isImportant || univ.category.isNotEmpty)) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (univ.isImportant)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                          child: Text(
                            '重要',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: const Color.fromARGB(
                                        255,
                                        240,
                                        247,
                                        255,
                                      ),
                                    ),
                          ),
                        ),
                      if (univ.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          child: Text(
                            univ.category,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: HtmlWidget(
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
              ),
              if (notice.url.isNotEmpty || notice.files.isNotEmpty) ...[
                const Divider(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12),
                  child: Text(
                    '添付ファイル',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
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
            ],
          ),
        ),
      ],
    );
  }
}

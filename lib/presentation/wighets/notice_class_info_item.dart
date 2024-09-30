import 'package:aitapp/application/state/notice_load/notice_load.dart';
import 'package:aitapp/domain/types/class_notice.dart';
import 'package:aitapp/domain/types/notice.dart';
import 'package:aitapp/domain/types/univ_notice.dart';
import 'package:aitapp/presentation/screens/notice_detail.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NoticeClassInfoItem extends ConsumerWidget {
  const NoticeClassInfoItem({
    super.key,
    required this.notice,
    required this.isCommon,
    required this.page,
  });

  final Notice notice;
  final bool isCommon;
  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          if (!ref.read(noticeLoadNotifierProvider)) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (ctx) {
                  return NoticeDetailScreen(
                    index: notice.index,
                    isCommon: isCommon,
                    title: notice.title,
                    page: page,
                  );
                },
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトルと重要ラベル
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notice.isInportant)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '重要',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      notice.title,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '送信者: ${notice.sender}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

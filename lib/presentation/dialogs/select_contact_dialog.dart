import 'package:aitapp/domain/types/contact.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectContactDialog extends StatelessWidget {
  const SelectContactDialog({super.key, required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text(
        '連絡方法の選択',
      ),
      children: [
        SimpleDialogOption(
          onPressed: () {
            launchUrl(
              Uri(
                scheme: 'tel',
                path: contact.phone,
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '電話',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                contact.phone,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        if (contact.mail != null) ...{
          SimpleDialogOption(
            onPressed: () {
              launchUrl(
                Uri(
                  scheme: 'mailto',
                  path: contact.mail,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'メール',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  width: 50,
                ),
                Text(
                  contact.mail!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        },
      ],
    );
  }
}

import 'package:flutter/material.dart';

class Attachment extends StatelessWidget {
  const Attachment({
    super.key,
    required this.attachName,
    required this.onTap,
    required this.isUrl,
  });

  final String attachName;
  final void Function()? onTap;
  final bool isUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Icon(
              isUrl ? Icons.web_outlined : Icons.file_copy,
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                attachName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

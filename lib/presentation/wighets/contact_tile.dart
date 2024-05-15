import 'package:aitapp/domain/types/contact.dart';
import 'package:aitapp/presentation/dialogs/select_contact_dialog.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({super.key, required this.contact});
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contact.name),
      subtitle: Text(contact.explain),
      onTap: () {
        showDialog<Widget>(
          context: context,
          builder: (context) {
            return SelectContactDialog(
              contact: contact,
            );
          },
        );
      },
    );
  }
}

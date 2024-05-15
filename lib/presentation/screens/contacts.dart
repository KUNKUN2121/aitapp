import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/domain/types/contact.dart';
import 'package:aitapp/presentation/wighets/contact_tile.dart';
import 'package:flutter/material.dart';

class Contacts extends StatelessWidget {
  const Contacts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text('各所連絡先'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          if (contacts[index] is Contact) {
            return ContactTile(contact: contacts[index] as Contact);
          } else {
            return ListTile(
              title: Text(
                contacts[index] as String,
              ),
              tileColor: Theme.of(context).colorScheme.secondaryContainer,
            );
          }
        },
      ),
    );
  }
}

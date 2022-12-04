// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/models/userModel.dart';
import 'package:whatsapp_ui/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_ui/utils/utils.dart';

final selectContactRepositoryProvider = Provider(
  ((ref) => SelectContactRepository(firestore: FirebaseFirestore.instance)),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({
    required this.firestore,
  });

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('users').get();
      bool ifFound = false;

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNum =
            selectedContact.phones[0].number.toString().replaceAll(
                  ' ',
                  '',
                );
        if (selectedPhoneNum == userData.phoneNumber) {
          //showSnackBar(context: context, content: "${userData.phoneNumber}");
          ifFound = true;
          Navigator.pushNamed(context, MobileChatScreen.routeName, arguments: {
            'name': userData.name,
            'uid': userData.uid,
            'profilePic': '',
          });
          // Navigator.pushNamed(
          //   context,
          //   MobileChatScreen.routeName,
          //   arguments: {
          //     'name': userData.name,
          //     'uid': userData.uid,
          //   },
          // );
        }
      }

      if (!ifFound) {
        showSnackBar(
            context: context,
            content: "This Number not exists in this platform");
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/provider/message_reply_provider.dart';
import 'package:whatsapp_ui/common/repositories/common_firebase_storage_repos.dart';
import 'package:whatsapp_ui/models/chat_contact.dart';
import 'package:whatsapp_ui/models/message.dart';
import 'package:whatsapp_ui/models/userModel.dart';
import 'package:whatsapp_ui/utils/utils.dart';

final chatRepositoryProvider = Provider(
  ((ref) => ChatRepository(
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      )),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);

        contacts.add(
          ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveDataToContactSubCollection(
    UserModel senderUserData,
    UserModel recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
  ) async {
    //users->reciever user id -> chats ->current userId->set data
    //users->current user id -> chats ->reciever userId->set data
    var recieverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(
          recieverChatContact.toMap(),
        );
    var senderChatContact = ChatContact(
      name: recieverUserData.name,
      profilePic: recieverUserData.profilePic,
      contactId: recieverUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String recieverUsername,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String recieverUserName,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMesssage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : recieverUserName,
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel recieverUserData;
      var userDataMap =
          await firestore.collection('users').doc(recieverUserId).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();
      _saveDataToContactSubCollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        recieverUserId,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        recieverUsername: recieverUserData.name,
        messageType: MessageEnum.text,
        messageReply: messageReply,
        recieverUserName: recieverUserData.name,
        senderUsername: senderUser.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserid,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum, // required String recieverUserId,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserid/$messageId',
              file);

      UserModel recieverUserData;
      var userDataMap =
          await firestore.collection('users').doc(recieverUserid).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'gif';
          break;
        default:
          contactMsg = 'gif';
      }
      _saveDataToContactSubCollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserid,
      );
      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserid,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        recieverUsername: recieverUserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        recieverUserName: recieverUserData.name,
        senderUsername: senderUserData.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel recieverUserData;
      var userDataMap =
          await firestore.collection('users').doc(recieverUserId).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();
      _saveDataToContactSubCollection(
        senderUser,
        recieverUserData,
        'GIF',
        timeSent,
        recieverUserId,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        recieverUsername: recieverUserData.name,
        messageType: MessageEnum.gif,
        messageReply: messageReply,
        recieverUserName: recieverUserData.name,
        senderUsername: senderUser.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  // void sendLinkMessage({
  //   required BuildContext context,
  //   required String text,
  //   required String recieverUserId,
  //   required UserModel senderUser,
  // }) async {
  //   try {
  //     var timeSent = DateTime.now();
  //     UserModel recieverUserData;
  //     var userDataMap =
  //         await firestore.collection('users').doc(recieverUserId).get();
  //     recieverUserData = UserModel.fromMap(userDataMap.data()!);

  //     var messageId = const Uuid().v1();
  //     _saveDataToContactSubCollection(
  //       senderUser,
  //       recieverUserData,
  //       '🔗link',
  //       timeSent,
  //       recieverUserId,
  //     );

  //     _saveMessageToMessageSubcollection(
  //       recieverUserId: recieverUserId,
  //       text: text,
  //       timeSent: timeSent,
  //       messageId: messageId,
  //       username: senderUser.name,
  //       recieverUsername: recieverUserData.name,
  //       messageType: MessageEnum.link,
  //     );
  //   } catch (e) {
  //     showSnackBar(context: context, content: e.toString());
  //   }
  // }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

    //  showSnackBar(context: context, content: messageId);
      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}

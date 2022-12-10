import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/auth/controller/authcontroller.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/calls/screens/call_screen.dart';
import 'package:whatsapp_ui/features/calls/screens/call_pickup_screen.dart';
import 'package:whatsapp_ui/features/chat/widgets/bottomChatField.dart';
import 'package:whatsapp_ui/features/chat/widgets/chat_list.dart';
import 'package:whatsapp_ui/models/userModel.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final String profilePic;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.profilePic,
  }) : super(key: key);

  void makeCall(WidgetRef ref, BuildContext context) {
    ref
        .read(callControllerProvider)
        .makeCall(context, name, uid, profilePic, false);
  }

  void makeVoiceCall(WidgetRef ref, BuildContext context) {
    ref
        .read(callControllerProvider)
        .makeVoiceCall(context, name, uid, profilePic, false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: StreamBuilder<UserModel>(
              stream: ref.read(authControllerProvider).userDataById(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                return Column(
                  children: [
                    Text(name),
                    Text(
                      snapshot.data!.isOnline ? 'online' : 'offline',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.normal),
                      textAlign: TextAlign.left,
                    ),
                  ],
                );
              }),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () => makeCall(ref, context),
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed: () => makeVoiceCall(ref, context),
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatList(
                recieverUserId: uid,
              ),
            ),
            BottomChatField(
              recieverUserId: uid,
            ),
          ],
        ),
      ),
    );
  }
}

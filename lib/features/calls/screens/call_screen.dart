import 'package:agora_uikit/agora_uikit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/config/agora_config.dart';
import 'package:whatsapp_ui/features/calls/controller/call_controller.dart';
import 'package:whatsapp_ui/features/calls/repository/call_repository.dart';
import 'package:whatsapp_ui/models/call.dart';
import 'package:whatsapp_ui/utils/utils.dart';

final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(
    callRepository: callRepository,
    auth: FirebaseAuth.instance,
    ref: ref,
  );
});

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final String id;
  final bool isGroupChat;
  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.id,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  // AgoraClient? client;
  // String baseUrl = 'http://localhost:8080/';

  // @override
  // void initState() {
  //   super.initState();
  //   client = AgoraClient(
  //       agoraConnectionData: AgoraConnectionData(
  //         appId: AgoraConfig.appId,
  //         channelName: "test",
  //         tempToken:
  //             "007eJxTYDDr/ZzC2WZxZudVtuLiFuOJeyqltco/2X/uMOG7Y3hxi5ECQ5pBanKiYYqlkUmSiUmKWaolkJ2UaJFmmmpunmiUZnH8W1dyQyAjQxj3fGZGBggE8VkYSlKLSxgYAEjvH8k=",
  //       ),
  //       enabledPermission: [Permission.videos, Permission.microphone]);
  //   initAgora();
  //   debugPrint(client.toString() + "this is client ");
  // }

  // void initAgora() async {
  //   await client!.initialize();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZegoUIKitPrebuiltCall(
        appID:
            1048787657, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
        appSign:
            '1da299653e939fe180a327c86702c0fadf4440901decba61035dd83d4720dd48', // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        userID: widget.id,
        userName: 'user${widget.id}',
        callID: widget.channelId,
        // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
        config: ZegoUIKitPrebuiltCallConfig.groupVideoCall()
          ..onHangUp = () {
            Navigator.pop(context);
            ref
                .read(callControllerProvider)
                .endCall(widget.call.callerId, widget.call.receiverId, context);
          },
      ),
    );
  }
}

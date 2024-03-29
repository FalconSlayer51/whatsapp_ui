import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/calls/screens/call_screen.dart';
import 'package:whatsapp_ui/features/calls/screens/voice_call.dart';
import 'package:whatsapp_ui/models/call.dart';

class CallPickupScreen extends ConsumerWidget {
  final Widget scaffold;
  const CallPickupScreen({
    Key? key,
    required this.scaffold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerProvider).callStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call call =
              Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          if (!call.hasDialled) {
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Incoming Call",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage(call.callerPic),
                      radius: 60,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      call.callerName,
                      style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins'),
                    ),
                    const SizedBox(
                      height: 75,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            ref
                                .read(callControllerProvider)
                                .endCall(call.callId, call.receiverId, context);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.call_end),
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        IconButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(call.callerId)
                                .collection('calls')
                                .doc(call.callId)
                                .update({'isLifted': true});

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(call.receiverId)
                                .collection('calls')
                                .doc(call.callId)
                                .update({'isLifted': true});

                            if (call.type == 'voiceCall') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VoiceCallScreen(
                                    channelId: call.callId,
                                    call: call,
                                    id: call.receiverId,
                                    isGroupChat: false,
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(
                                  channelId: call.callId,
                                  call: call,
                                  id: call.receiverId,
                                  isGroupChat: false,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.call),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return scaffold;
      },
    );
  }
}

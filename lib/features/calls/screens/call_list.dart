import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/calls/screens/call_screen.dart';
import 'package:whatsapp_ui/models/call.dart';

class CallList extends ConsumerStatefulWidget {
  const CallList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallListState();
}

class _CallListState extends ConsumerState<CallList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Call>>(
        stream: ref.read(callControllerProvider).getCallStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final callData = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(callData.callerPic),
                    radius: 30,
                  ),
                  title: Text(
                    callData.callerName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'to :' + callData.receiverName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  trailing: callData.isLifted == false
                      ? Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                          ),
                          child: Icon(Icons.call_missed_outgoing),
                        )
                      : callData.callerId ==
                                  FirebaseAuth.instance.currentUser!.uid &&
                              callData.isLifted == true
                          ? Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: tabColor,
                              ),
                              child: Icon(Icons.call_made),
                            )
                          : Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: tabColor,
                              ),
                              child: Icon(Icons.call_received),
                            ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

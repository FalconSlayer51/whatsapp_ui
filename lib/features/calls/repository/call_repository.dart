import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/calls/screens/call_screen.dart';
import 'package:whatsapp_ui/features/calls/screens/voice_call.dart';
import 'package:whatsapp_ui/models/call.dart';
import 'package:whatsapp_ui/utils/utils.dart';

final callRepositoryProvider = Provider(
  (ref) => CallRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  CallRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream =>
      firestore.collection('call').doc(auth.currentUser!.uid).snapshots();

  void makeCall(
    Call senderCallData,
    BuildContext context,
    Call receiverCallData,
  ) async {
    try {
      await firestore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await firestore
          .collection('call')
          .doc(senderCallData.receiverId)
          .set(receiverCallData.toMap());

      await firestore
          .collection('users')
          .doc(senderCallData.callerId)
          .collection('calls')
          .doc(senderCallData.callId)
          .set(senderCallData.toMap());
      await firestore
          .collection('users')
          .doc(senderCallData.receiverId)
          .collection('calls')
          .doc(receiverCallData.callId)
          .set(receiverCallData.toMap());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            channelId: senderCallData.callId,
            call: senderCallData,
            isGroupChat: false,
            id: senderCallData.callerId,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void makeVoiceCall(
    Call senderCallData,
    BuildContext context,
    Call receiverCallData,
  ) async {
    try {
      await firestore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await firestore
          .collection('call')
          .doc(senderCallData.receiverId)
          .set(receiverCallData.toMap());

      await firestore
          .collection('users')
          .doc(senderCallData.callerId)
          .collection('calls')
          .doc(senderCallData.callId)
          .set(senderCallData.toMap());
      await firestore
          .collection('users')
          .doc(senderCallData.receiverId)
          .collection('calls')
          .doc(receiverCallData.callId)
          .set(receiverCallData.toMap());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoiceCallScreen(
            channelId: senderCallData.callId,
            call: senderCallData,
            isGroupChat: false,
            id: senderCallData.callerId,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await firestore.collection('call').doc(callerId).delete();
      await firestore.collection('call').doc(receiverId).delete();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<List<Call>> getCallData() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('calls')
        .snapshots()
        .map((event) {
      List<Call> callData = [];
      for (var document in event.docs) {
        callData.add(
          Call.fromMap(
            document.data(),
          ),
        );
      }
      return callData;
    });
  }
}

// ignore_for_file: use_key_in_widget_constructors

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/status/controller/status_controller.dart';
import 'package:whatsapp_ui/utils/utils.dart';
// import 'package:stack_trace/stack_trace.dart' as stack_trace;

// import 'package:stack_trace/stack_trace.dart' as stack_trace;

// // ignore: non_constant_identifier_names
// Function(StackTrace stack) demangleStackTrace = (StackTrace stack) {
//   if (stack is stack_trace.Trace) return stack.vmTrace;
//   if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
//   return stack;
// };

class ConfirmStatusScreen extends ConsumerWidget {
  static const String routeName = '/confirm-status-screen';
  final File pickedImage;
  const ConfirmStatusScreen({
    required this.pickedImage,
  });

  void addStatus(WidgetRef ref, BuildContext context) {
    ref.read(statusControllerProvider).addStatus(pickedImage, context);
    showSnackBar(context: context, content: 'status sent');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(pickedImage),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addStatus(ref, context);
        },
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}

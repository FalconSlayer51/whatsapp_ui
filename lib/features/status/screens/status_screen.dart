import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';

import 'package:whatsapp_ui/models/status_model.dart';

class StatusScreen extends StatefulWidget {
  static const String routeName = '/status-screen';
  final Status status;
  const StatusScreen({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StoryController storyController = StoryController();
  List<StoryItem> imgs = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    initStoryPageItems();
  }

  void initStoryPageItems() {
    for (int i = 0; i < widget.status.photoUrl.length; i++) {
      imgs.add(
        StoryItem.pageImage(
          url: widget.status.photoUrl[i],
          controller: storyController,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        systemOverlayStyle: const SystemUiOverlayStyle(
          // Status bar color
          systemNavigationBarDividerColor: Colors.white,
          systemNavigationBarColor: mobileChatBoxColor,
          statusBarColor: Colors.black,
        ),
        title: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.status.profilePic,
                  scale: 10,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.status.username,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    DateFormat.yMMMEd().format(widget.status.createdAt),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: imgs.isEmpty
          ? const Loader()
          : StoryView(
              onComplete: () => Navigator.pop(context),
              storyItems: imgs,
              controller: storyController,
              onVerticalSwipeComplete: (p0) {
                if (p0 == Direction.down) {
                  Navigator.pop(context);
                }
              },
            ),
    );
  }
}

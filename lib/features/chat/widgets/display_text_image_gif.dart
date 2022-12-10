import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/features/chat/widgets/videoplayeritem.dart';

class DisplayTextImageGif extends StatelessWidget {
  final String message;
  final MessageEnum type;
  const DisplayTextImageGif({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();
    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          )
        : type == MessageEnum.audio
            ? StatefulBuilder(builder: (context, setState) {
                return Container(
                  color: Colors.white38,
                  child: IconButton(
                    color: dividerColor,
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                        setState(() {
                          isPlaying = false;
                        });

                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        await audioPlayer.play(UrlSource(message));
                        if (audioPlayer.getDuration() ==
                            audioPlayer.getCurrentPosition()) {
                          setState(() {
                            isPlaying = false;
                          });
                        }
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    },
                    icon: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic),
                        const SizedBox(
                          width: 50,
                        ),
                        Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 200,
                    ),
                  ),
                );
              })
            : type == MessageEnum.video
                ? VideoPlayerItem(videourl: message)
                : type == MessageEnum.gif
                    ? CachedNetworkImage(imageUrl: message)
                    : CachedNetworkImage(
                        imageUrl: message,
                      );
  }
}

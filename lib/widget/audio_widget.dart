import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lap26_3/model/Slide.dart';
import 'package:lap26_3/utils/color_utils.dart';

class AudioWidget extends StatelessWidget {
  final SlideElement element;
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final Function(bool) onPlayPause;
  final double width;
  final double height;

  const AudioWidget({
    super.key,
    required this.element,
    required this.audioPlayer,
    required this.isPlaying,
    required this.onPlayPause,
    required this.width,
    required this.height,
  });

  // Chuyển đổi trạng thái phát/tạm dừng
  void toggleAudioPlayPause() {
    if (isPlaying) {
      audioPlayer.pause();
      onPlayPause(false);
    } else {
      audioPlayer.play();
      onPlayPause(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return element.src != null
        ? FittedBox(
      fit: BoxFit.scaleDown,
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.volume_up_outlined : Icons.volume_off_outlined,
          size: height ,
          color: element.color != null
              ? parseColor(element.color!)
              : Colors.black,
        ),
        onPressed: toggleAudioPlayPause,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    )
        : const SizedBox.shrink();
  }
}
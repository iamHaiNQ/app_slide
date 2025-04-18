import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lap26_3/model/Slide.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoWidget extends StatefulWidget {
  final SlideElement element;
  final double width;
  final double height;

  const VideoWidget({
    super.key,
    required this.element,
    required this.width,
    required this.height,
  });

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  BetterPlayerController? betterPlayerController;
  YoutubePlayerController? youtubeController;

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    if (widget.element.type == 'video' && widget.element.src != null) {
      bool isYouTubeUrl = widget.element.src!.contains('youtube.com') ||
          widget.element.src!.contains('youtu.be');
      if (widget.element.isYouTubeLink == true || isYouTubeUrl) {
        youtubeController = YoutubePlayerController(
          initialVideoId:
          YoutubePlayer.convertUrlToId(widget.element.src!) ?? '',
          flags: YoutubePlayerFlags(
            autoPlay: widget.element.autoplay ?? false,
          ),
        );
      } else {
        betterPlayerController = BetterPlayerController(
          BetterPlayerConfiguration(
            autoPlay: widget.element.autoplay ?? false,
          ),
          betterPlayerDataSource: BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            widget.element.src!,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    betterPlayerController?.dispose();
    youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isYouTubeUrl = widget.element.src!.contains('youtube.com') ||
        widget.element.src!.contains('youtu.be');
    if ((widget.element.isYouTubeLink == true || isYouTubeUrl) &&
        widget.element.src != null &&
        youtubeController != null) {
      return YoutubePlayer(
        controller: youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
      );
    } else if (widget.element.src != null && betterPlayerController != null) {
      return BetterPlayer(
        controller: betterPlayerController!,
      );
    }
    return const SizedBox.shrink();
  }
}
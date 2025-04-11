
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:lap26_3/model/Slide.dart';
import 'package:lap26_3/utils/color_utils.dart';
import 'package:lap26_3/widget/image_widget.dart';
import 'package:lap26_3/widget/text_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:just_audio/just_audio.dart';

class SlideWidget extends StatefulWidget {
  final Slide slide;

  const SlideWidget({super.key, required this.slide});

  @override
  _SlideWidgetState createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<SlideWidget> {
  Map<String, BetterPlayerController> betterPlayerControllers = {};
  Map<String, YoutubePlayerController> youtubeControllers = {};
  Map<String, AudioPlayer> audioPlayers = {};
  Map<String, bool> isAudioPlaying = {};
  Map<String, bool> isAudioMuted = {};

  @override
  void initState() {
    initializeMedia();
    super.initState();
  }

  void toggleAudioPlayPause(String id) {
    final player = audioPlayers[id];
    if (player != null) {
      setState(() {
        if (isAudioPlaying[id] == true) {
          player.pause();
          isAudioPlaying[id] = false;
        } else {
          player.play();
          isAudioPlaying[id] = true;
        }
      });
    }
  }

  Future<void> initializeMedia() async {
    for (var element in widget.slide.elements) {
      if (element.type == 'video' && element.src != null) {
        bool isYouTubeUrl = element.src!.contains('youtube.com') ||
            element.src!.contains('youtu.be');
        if (element.isYouTubeLink == true || isYouTubeUrl) {
          final youtubeController = YoutubePlayerController(
            initialVideoId: YoutubePlayer.convertUrlToId(element.src!) ?? '',
            flags: YoutubePlayerFlags(
              autoPlay: element.autoplay ?? false,
            ),
          );
          youtubeControllers[element.id] = youtubeController;
        } else {
          final controller = BetterPlayerController(
            BetterPlayerConfiguration(
              autoPlay: element.autoplay ?? false,
            ),
            betterPlayerDataSource: BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              element.src!,
            ),
          );
          betterPlayerControllers[element.id] = controller;
        }
      } else if (element.type == 'audio' && element.src != null) {
        final player = AudioPlayer();
        audioPlayers[element.id] = player;
        isAudioPlaying[element.id] = false;
        isAudioMuted[element.id] = false;

        try {
          await player.setUrl(element.src!);
          if (element.autoplay == true) {
            await player.play();
            setState(() {
              isAudioPlaying[element.id] = true;
            });
          }
          if (element.loop == true) {
            await player.setLoopMode(LoopMode.one);
          }
        } catch (error) {
          print('Lỗi khi tải audio ${element.id}: $error');
        }
      }
    }
  }

  @override
  void dispose() {
    betterPlayerControllers.forEach((_, controller) => controller.dispose());
    youtubeControllers.forEach((_, controller) => controller.dispose());
    audioPlayers.forEach((_, player) => player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final slideWidth = screenSize.width;
    final slideHeight = screenSize.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: slideWidth,
            height: slideHeight,
            color: Color(int.parse(
                widget.slide.background.color.replaceAll('#', '0xff'))),
            child: Stack(
              children: widget.slide.elements.map((element) {
                return buildElementContent(element, slideWidth, slideHeight);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildElementContent(
      SlideElement element, double slideWidth, double slideHeight) {
    double scaleX = slideWidth / 1000;
    double scaleY = slideHeight / 562.5;

    double left = element.left * scaleX;
    double top = element.top * scaleY;
    double width = element.width * scaleX;
    double height = (element.height ?? 0) * scaleY;

    print('Top: $top, Left: $left, Width: $width, Height: $height');

    return Transform.translate(
      offset: Offset(left, top),
      child: SizedBox(
        width: width,
        height: height,
        child: buildWidgetByType(element, width, height),
      ),
    );
  }

  Widget buildWidgetByType(SlideElement element, double width, double height) {
    final slideWidth = MediaQuery.of(context).size.width;
    final scaleFactor = slideWidth / 1000;
    switch (element.type) {
      case 'text':
        return TextWidget(
          element: element,
          width: width,
          height: height,
          scaleFactor: scaleFactor,
        );
      case 'image':
        return ImageElementWidget(
          element: element,
          width: width,
          height: height,
        );
      case 'video':
        bool isYouTubeUrl = element.src!.contains('youtube.com') ||
            element.src!.contains('youtu.be');
        if ((element.isYouTubeLink == true || isYouTubeUrl) &&
            element.src != null &&
            youtubeControllers.containsKey(element.id)) {
          return YoutubePlayer(
            controller: youtubeControllers[element.id]!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
          );
        } else if (element.src != null &&
            betterPlayerControllers.containsKey(element.id)) {
          return BetterPlayer(
            controller: betterPlayerControllers[element.id]!,
          );
        }
        return const SizedBox.shrink();
      case 'audio':
        return element.src != null && audioPlayers.containsKey(element.id)
            ? FittedBox(
          fit: BoxFit.scaleDown,
          child: IconButton(
            icon: Icon(
              isAudioPlaying[element.id] == true
                  ? Icons.volume_up_outlined
                  : Icons.volume_off_outlined,
              size: height * 0.8,
              color: element.color != null
                  ? parseColor(element.color!)
                  : Colors.black,
            ),
            onPressed: () => toggleAudioPlayPause(element.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        )
            : const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}

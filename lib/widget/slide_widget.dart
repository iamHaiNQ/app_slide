import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lap26_3/model/Slide.dart';
import 'package:lap26_3/utils/audio_time_line.dart';
import 'package:lap26_3/widget/image_widget.dart';
import 'package:lap26_3/widget/text_widget.dart';
import 'package:lap26_3/widget/video_widget.dart';

import 'audio_widget.dart';

class SlideWidget extends StatefulWidget {
  final Slide slide;

  const SlideWidget({super.key, required this.slide});

  @override
  _SlideWidgetState createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<SlideWidget> {
  // Quản lý các AudioPlayer cho các phần tử audio
  Map<String, AudioPlayer> audioPlayers = {};

  // Theo dõi trạng thái phát của từng audio
  Map<String, bool> isAudioPlaying = {};

  @override
  void initState() {
    super.initState();
    initializeAudio();
  }

  // Khởi tạo AudioPlayer cho các phần tử audio
  Future<void> initializeAudio() async {
    for (var element in widget.slide.elements) {
      if (element.type == 'audio' && element.src != null) {
        final player = AudioPlayer();
        audioPlayers[element.id] = player;
        isAudioPlaying[element.id] = false;

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
    // Giải phóng tất cả AudioPlayer khi widget bị hủy
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
              // Tạo danh sách widget, bao gồm cả AudioWidget và AudioTimelineWidget cho audio
              children: widget.slide.elements.expand((element) {
                List<Widget> widgets = [];
                widgets
                    .add(buildElementContent(element, slideWidth, slideHeight));
                // Chỉ thêm AudioTimelineWidget nếu audio đang phát
                if (element.type == 'audio' &&
                    element.src != null &&
                    isAudioPlaying[element.id] == true) {
                  widgets.add(
                      buildTimelineContent(element, slideWidth, slideHeight));
                }
                return widgets;
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // Xây dựng nội dung cho từng phần tử (text, image, video, audio)
  Widget buildElementContent(
      SlideElement element, double slideWidth, double slideHeight) {
    double scaleX = slideWidth / 1000;
    double scaleY = slideHeight / 562.5;

    double left = element.left * scaleX;
    double top = element.top * scaleY;
    double width = element.width * scaleX;
    double height = (element.height ?? 0) * scaleY;

    print('Top: $top, Left: $left, Width: $width, Height: $height');

    Widget content = SizedBox(
      width: width,
      height: height,
      child: buildWidgetByType(element, width, height),
    );

    if (element.rotate != null && element.rotate != 0) {
      content = Transform.rotate(
        angle: element.rotate! * 3.1415926535 / 180, // Chuyển độ sang radian
        child: content,
      );
    }

    return Transform.translate(
      offset: Offset(left, top),
      child: content,
    );
  }

  // Xây dựng widget timeline cho audio, đặt bên dưới AudioWidget
  Widget buildTimelineContent(
      SlideElement element, double slideWidth, double slideHeight) {
    double scaleX = slideWidth / 1000;
    double scaleY = slideHeight / 562.5;

    // Định vị timeline ngay dưới AudioWidget
    double left = element.left * scaleX;
    double top = (element.top + (element.height ?? 0)) * scaleY;
    double width = 300;
    double height = 50; // Chiều cao cố định cho timeline

    return Transform.translate(
      offset: Offset(left, top),
      child: SizedBox(
        width: width,
        height: height,
        child: AudioTimelineWidget(
          element: element,
          audioPlayer: audioPlayers[element.id]!,
          width: width,
          height: height,
        ),
      ),
    );
  }

  // Chọn loại widget dựa trên loại phần tử
  Widget buildWidgetByType(SlideElement element, double width, double height) {
    final slideWidth = MediaQuery.of(context).size.height;
    const scaleFactor = 0.5;
    switch (element.type) {
      case 'text':
        return TextWidget(
          element: element,
          scaleFactor: scaleFactor,
          width: width,
          height: height,
        );
      case 'image':
        return ImageElementWidget(
          element: element,
          width: width,
          height: height,
        );
      case 'video':
        return VideoWidget(
          element: element,
          width: width,
          height: height,
        );
      case 'audio':
        return AudioWidget(
          element: element,
          audioPlayer: audioPlayers[element.id]!,
          isPlaying: isAudioPlaying[element.id] ?? false,
          onPlayPause: (isPlaying) {
            setState(() {
              isAudioPlaying[element.id] = isPlaying;
            });
          },
          width: width,
          height: height,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

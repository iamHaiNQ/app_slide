import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lap26_3/model/Slide.dart';
import 'color_utils.dart';

class AudioTimelineWidget extends StatefulWidget {
  final SlideElement element;
  final AudioPlayer audioPlayer;
  final double width;
  final double height;

  const AudioTimelineWidget({
    super.key,
    required this.element,
    required this.audioPlayer,
    required this.width,
    required this.height,
  });

  @override
  _AudioTimelineWidgetState createState() => _AudioTimelineWidgetState();
}

class _AudioTimelineWidgetState extends State<AudioTimelineWidget> {
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi thời lượng và vị trí của audio
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        duration = d ?? Duration.zero;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        position = p;
      });
    });
  }

  // Tua audio đến vị trí được chọn
  void seekAudio(double value) {
    final newPosition = duration * value;
    widget.audioPlayer.seek(newPosition);
  }

  // Định dạng thời gian thành MM:SS
  String formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Thanh trượt (Slider) chiếm toàn bộ chiều rộng
        Positioned(
          top: 0,
          left: 0,
          width: widget.width,
          height: 20,
          child: Slider(
            value: duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0,
            onChanged: (value) {
              seekAudio(value);
            },
            activeColor: widget.element.color != null
                ? parseColor(widget.element.color!)
                : Colors.blue,
            inactiveColor: Colors.grey,
            thumbColor: Colors.blue,
            min: 0.0,
            max: 1.0,
          ),
        ),
        // Văn bản thời gian đặt ở cạnh dưới của thanh trượt
        Positioned(
          bottom: 2,
          right: 10,
          width: widget.width,
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end, // Căn đều hai đầu
            children: [
              Text(
                formatDuration(position),
                style: TextStyle(
                  fontSize: 14, // 2.5 pixels
                  color: widget.element.color != null
                      ? parseColor(widget.element.color!)
                      : Colors.black,
                ),
              ),
              Text(
                '/',
                style: TextStyle(
                  fontSize: 14, // 2.5 pixels
                  color: widget.element.color != null
                      ? parseColor(widget.element.color!)
                      : Colors.black,
                ),
              ),
              Text(
                formatDuration(duration),
                style: TextStyle(
                  fontSize: 14, // 2.5 pixels
                  color: widget.element.color != null
                      ? parseColor(widget.element.color!)
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
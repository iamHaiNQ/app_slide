import 'package:flutter/material.dart';
import 'package:lap26_3/model/Slide.dart';
import 'package:lap26_3/widget/slide_widget.dart';

class HomePage extends StatefulWidget {
  final List<Slide> slides;
  const HomePage({Key? key, required this.slides}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_pageController.hasClients &&
        _pageController.page! < widget.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _prevSlide() {
    if (_pageController.hasClients && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.slides.length,
            itemBuilder: (context, index) {
              return SlideWidget(slide: widget.slides[index]);
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: ElevatedButton(
              onPressed: _prevSlide,
              child: const Text('◀ Trước'),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: _nextSlide,
              child: const Text('Sau ▶'),
            ),
          ),
        ],
      ),
    );
  }
}